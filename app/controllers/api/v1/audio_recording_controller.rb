class Api::V1::AudioRecordingController < ApplicationController
    def index
      
      @audio_recordings = AudioRecording.order(created_at: :desc).paginate(page: params[:page], per_page: 10)

      total_pages = @audio_recordings.total_pages
  
      response.headers['X-Total-Pages'] = total_pages.to_s
      render json: @audio_recordings, status: :ok
    end
  
    def show
        @audio_recording = AudioRecording.find(params[:id])

        render json: { 'data': @audio_recording, 'url': url_for(@audio_recording.audio_data) }, status: :ok
    end

    def update
        @audio_recording = AudioRecording.find(params[:id])

        # if(params.has_key?(:name))
        #     @audio_recording.name = params[:name]
        # elsif (params.has_key?(:category))
        #     @audio_recording.category = params[:category]
        # elsif (params.has_key?(:comment))
        #     @audio_recording.comment = params[:comment]
        # end

        if @audio_recording.update(audio_recording_params)
            render json: { message: "Recording updated successfully", user: @audio_recording }, status: :ok
        else
            render json: { errors: @audio_recording.errors }, status: :unprocessable_entity
        end

    end

    def create
    
        # require "uri"
        # require "net/http"

        # url = URI("https://api.openai.com/v1/audio/transcriptions")

        # https = Net::HTTP.new(url.host, url.port)
        # https.use_ssl = true

        # request = Net::HTTP::Post.new(url)
        
        # request["Authorization"] = "Bearer " + Rails.application.credentials.openai.access_key
        # form_data = [['', params['audio_data']],['model', 'whisper-1']]
        # request.set_form form_data, 'multipart/form-data'
        # response = https.request(request)
                              
        @audio_recording = AudioRecording.new
        
        # # Check if the request was successful
        # if response.is_a?(Net::HTTPSuccess)
        #     # Process the response body
        #     @audio_recording.transcription = response.body.data
        #     puts response.body
        # else
        #     puts "Request failed with status #{response.code}: #{response.message}"
        #     render json: {message: "Transcription service failed"}, status: :unprocessable_entity
        #     return
        # end

        @audio_recording.audio_data.attach(params[:audio_data])
        @audio_recording.audio_url = @audio_recording.audio_data.url

        p @audio_recording.audio_data.url

        p "audio-transcription-movious"

        if @audio_recording.save
            render json: { message: "File uploaded successfully", transcription:"", id: @audio_recording.id, url: @audio_recording.audio_data.url }, status: :created
        else
            p @audio_recording.errors
            render json: @audio_recording.errors, status: :unprocessable_entity
        end
    end

    private
    def audio_recording_params
      params.permit(:name, :category, :audio_url, :transcription, :comments)
    end
end