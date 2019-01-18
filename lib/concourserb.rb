require 'net/http'
require 'json'

class Concourserb

    def initialize(url, team, user, pass)
        @url = url
        @user = user
        @pass = pass
        @team = team
        auth()
    end

    def jobs(pipeline_name)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs")
    end

    def list_builds()
        return get("/api/v1/builds")
    end

    def get_build(build_id)
        return get("/api/v1/builds/#{build_id}")
    end

    def build(build_id)
        # leaving for backwards compatibility
        return get_build(build_id)
    end

    def get_build_plan(build_id)
        return get("/api/v1/builds/#{build_id}/plan")
    end

    def build_plan(build_id)
        return get_build_plan(build_id)
    end

    def send_input_to_build_plan(build_id, plan_id)
        return put("/api/v1/builds/#{build_id}/plan/#{plan_id}/input")
    end

    def read_output_from_build_plan(build_id, plan_id)
        return get("/api/v1/builds/#{build_id}/plan/#{plan_id}/output")
    end

    def build_events(build_id)
        return get("/api/v1/builds/#{build_id}/events")
    end

    def build_resources(build_id)
        return get("/api/v1/builds/#{build_id}/resources")
    end

    def abort_build(build_id)
        return put("/api/v1/builds/#{build_id}/abort")
    end

    def get_build_preperation(build_id)
        return get("/api/v1/builds/#{build_id}/preperation")
    end

    def list_resource_versions(pipeline_name, resource_name, limit=100)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions?limit=#{limit}")
    end

    def versions(pipeline_name, resource_name, limit=100)
        # backwards compat
        return list_resource_versions(pipeline_name, resource_name, limit)
    end

    def get_resource_version(pipeline_name, resource_name, resource_version_id)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_version_id}")
    end

    def list_builds_with_version_as_input(pipeline_name, resource_name, resource_id)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_id}/input_to")
    end

    def input_to(pipeline_name, resource_name, resource_id)
        return list_builds_with_version_as_input(pipeline_name, resource_name, resource_id)
    end

    def list_builds_with_version_as_output(pipeline_name, resource_name, resource_id)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_id}/output_to")
    end

    def output_of(pipeline_name, resource_name, resource_id)
        return list_builds_with_version_as_output(pipeline_name, resource_name, resource_id)
    end

    def create_job_build(pipeline_name, job_name)
      return post("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/builds")
    end

    def trigger(pipeline_name, job_name)
        # backwards compat
        return create_job_build(pipeline_name, job_name)
    end

    def enable_resource_version(pipeline_name, resource_name, version_id)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{version_id}/enable")
    end

    def enable(pipeline_name, resource_name, version_id)
        # backwards compat
        return enable_resource_version(pipeline_name, resource_name, version_id)
    end

    def disable_resource_version(pipeline_name, resource_name, version_id)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{version_id}/disable")
    end

    def disable(pipeline_name, resource_name, version_id)
        return disable_resource_version(pipeline_name, resource_name, version_id)
    end

    def pause_resource(pipeline_name, resource_name)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/pause")
    end

    def unpause_resource(pipeline_name, resource_name)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/unpause")
    end

    def list_all_jobs()
        return get("/api/v1/jobs")
    end

    def list_jobs(pipeline_name)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs")
    end

    def get_job(pipeline_name, job_name)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}")
    end

    def list_job_builds(pipeline_name, job_name)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/builds")
    end

    def list_job_inputs(pipeline_name, job_name)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/inputs")
    end

    def get_job_build(pipeline_name, job_name, build_name)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/builds/#{build_name}")
    end

    def pause_job(pipeline_name, job_name)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/pause")
    end

    def unpause_job(pipeline_name, job_name)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/unpause")
    end

    def job_badge(pipeline_name, job_name)
        return get("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/badge")
    end

    def main_job_badge(pipeline_name, job_name)
        return get("/api/v1/pipelines/#{pipeline_name}/jobs/#{job_name}/badge")
    end

    private

    def auth()
          # TODO fix this up to be cleaner; this is the first POC for concourse auth 4.0
          host = @URI.parse(@url)
          port = URI.parse(@url).port
          http = Net::HTTP.new(host, port)
          http.use_ssl = true
          request = Net::HTTP::Get.new("https://#{URI.parse(@url).host}/sky/login")
          response = http.request(request)
          case response
          when Net::HTTPSuccess then
              break
          when Net::HTTPRedirection then
              location = response['Location']
              cookie_value = response['set-cookie'].split(';')[0]
              if URI.parse(response['Location']).host
          else
              raise "unexpected response"
          cookie_value = response['set-cookie'].split(';')[0]
          request = Net::HTTP::Get.new(URI.parse(response['location']))
          request['Cookie'] = cookie_value
          response = http.request(request)
          next_url = URI.parse("#{URI.parse(@url).host}#{response.body.split("\n").select{ |x| x.include?('/sky/issuer/auth/local') }.first.strip.split('"')[1]}")
          request = Net::HTTP::Post.new("https://#{next_url}")
          request.set_form_data({'login': @user, 'password': @pass})
          request['Cookie'] = cookie_value
          response = http.request(request)
          next_url = "https://#{URI.parse(@url).host}#{response['location']}"
          request = Net::HTTP::Get.new(URI.parse(next_url))
          request['Cookie'] = cookie_value
          response = http.request(request)
          request = Net::HTTP::Get.new(URI.parse(response['location']))
          request['Cookie'] = cookie_value
          response = http.request(request)
          @ATC_auth =  response.to_hash['set-cookie'].select { |x| x.include?('skymarshal_auth="Bearer') }[0].split('"')[1].split(" ")[1]
          return true
    end

    def req(url, http_verb="GET", post_data={})
        http = Net::HTTP.new(URI.parse(@url).host, URI.parse(@url).port)
        http.use_ssl = true
        if http_verb.eql?('GET')
            request = Net::HTTP::Get.new(url)
        elsif http_verb.eql?('POST')
            request = Net::HTTP::Post.new(url)
            request.set_form_data(post_data)
        elsif http_verb.eql?('PUT')
            request = Net::HTTP::Put.new(url)
        else
            raise "http_verb not implemented: #{http_verb}"
        end
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "Bearer #{@ATC_auth}"
        response = http.request(request)
        if response.code == 401 or response.body.eql?('not authorized')
            # we got bad auth, so get a new token
            auth()
            request['Authorization'] = "Bearer #{@ATC_auth}"
            response = http.request(request)
        end
        if http_verb.eql?("PUT")
            if response.code.eql?('200')
                return true
            end
        end
        return JSON.parse(response.body)
    end

    def post(url, post_data={})
        return req(url, 'POST', post_data)
    end

    def put(url)
        return req(url, 'PUT')
    end

    def get(url)
        return req(url, 'GET')
    end
end
