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

    def versions(pipeline_name, resource_name)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions")
    end

    def input_to(pipeline_name, resource_name, resource_id)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_id}/input_to")
    end

    def output_of(pipeline_name, resource_name, resource_id)
        return req("/api/v1/teams/#{@team}/pipelines/#{pipeline_name}/resources/#{resource_name}/versions/#{resource_id}/output_of")
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

    def req(url)
        http = Net::HTTP.new(URI.parse(@url).host, URI.parse(@url).port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request['Content-Type'] = 'application/json'
        request['Cookie'] = "ATC-Authorization=Bearer #{@ATC_auth}"
        response = http.request(request)
        if response.code == 401
            # we got bad auth, so get a new token
            auth()
            request['Cookie'] = "ATC-Authorization=Bearer #{@ATC_auth}"
            response = http.request(request)
        end
        return JSON.parse(response.body)
    end

end