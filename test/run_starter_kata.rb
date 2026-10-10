# Piped into `ruby` inside the web pod by bin/test_traffic_light_saved.sh.
# Creates a "Bash, bats" kata through nginx, then runs its starter files through
# web's run_tests, as a browser does. The starter code answers 54 where its
# test expects 42, so the one correct outcome is red.
# Prints the new kata's id on success; exits non-zero with a message otherwise.
require 'json'
require 'net/http'
require 'uri'

LANGUAGE = 'Bash, bats'
EXERCISE = 'Fizz Buzz'
CSRF_TOKEN = 'test-traffic-light-saved'

def post_json(host, port, path, args)
  # Answers the parsed JSON reply to one JSON POST.
  http = Net::HTTP.new(host, port)
  http.read_timeout = 120
  reply = http.post(path, JSON.generate(args), 'Content-Type' => 'application/json')
  abort("POST #{host}#{path} answered #{reply.code}: #{reply.body[0, 500]}") unless reply.code == '200'
  JSON.parse(reply.body)
end

def post_run_tests(id, form)
  # Answers web's parsed JSON reply to one run_tests form POST, sent with the
  # double-submit CSRF token a browser holds as both cookie and header.
  http = Net::HTTP.new('nginx', 80)
  http.read_timeout = 120
  request = Net::HTTP::Post.new("/kata/run_tests/#{id}")
  request['Cookie'] = "csrf_token=#{CSRF_TOKEN}"
  request['X-CSRF-Token'] = CSRF_TOKEN
  request.set_form_data(form)
  reply = http.request(request)
  abort("run_tests answered #{reply.code}: #{reply.body[0, 500]}") unless reply.code == '200'
  JSON.parse(reply.body)
end

id = post_json('nginx', 80, '/creator/create.json',
               { type: 'kata', language_name: LANGUAGE, exercise_name: EXERCISE })['id']
manifest = post_json('languages-start-points', 4524, '/manifest', { name: LANGUAGE })['manifest']

form = {
  'image_name' => manifest['image_name'],
  'max_seconds' => (manifest['max_seconds'] || 10).to_s,
  'rag_lambda' => manifest['rag_lambda'].to_s,
  'index' => '1'
}
manifest['visible_files'].each do |filename, file|
  form["file_content[#{filename}]"] = file['content']
end

# A runner with an empty Docker daemon answers pulling until it has the image.
outcome = nil
60.times do
  outcome = post_run_tests(id, form)['outcome']
  break unless outcome == 'pulling'
  sleep 5
end
abort("kata #{id}: expected outcome red, got #{outcome}") unless outcome == 'red'
puts id
