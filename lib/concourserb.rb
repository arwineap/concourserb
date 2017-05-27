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

    def build_plan(build_id)
        return req("/api/v1/builds/#{build_id}/plan")
    end

    def build(build_id)
        return req("/api/v1/builds/#{build_id}")
    end

    def versions(pipeline_name, resource_name)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions")
    end

    def input_to(pipeline_name, resource_name, resource_id)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_id}/input_to")
    end

    def output_of(pipeline_name, resource_name, resource_id)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_id}/output_of")
    end

    def trigger(pipeline_name, job_name)
        return post("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/jobs/#{job_name}/builds")
    end

    def enable(pipeline_name, resource_name, version_id)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{version_id}/enable")
    end

    def disable(pipeline_name, resource_name, version_id)
        return put("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{version_id}/disable")
    end

    private

    def auth()
          http = Net::HTTP.new(URI.parse(@url).host, URI.parse(@url).port)
          http.use_ssl = true
          request = Net::HTTP::Get.new("/api/v1/teams/#{@team}/auth/token")
          request['Content-Type'] = 'application/json'
          request.basic_auth(@user, @pass)
          response = http.request(request)
          @ATC_auth = JSON.parse(response.body)["value"]
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
        if response.code == 401
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

end
