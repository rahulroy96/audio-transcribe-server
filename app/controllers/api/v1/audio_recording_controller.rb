class Api::V1::AudioRecordingController < ApplicationController
    before_action do
        ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
    end

    def index
      
      @audio_recordings = AudioRecording.order(created_at: :desc).paginate(page: params[:page], per_page: 10)

      @audio_recordings.each do |audio_recording|
        if audio_recording.audio_data.attached?
            audio_recording.audio_url = audio_recording.audio_data.url
        end
      end

      total_pages = @audio_recordings.total_pages
  
      response.headers['X-Total-Pages'] = total_pages.to_s
      render json: @audio_recordings, status: :ok
    end

    def destroy
        @audio_recording = AudioRecording.find_by(id: params[:id])
    
        if @audio_recording.nil?
            render json: { "message": "no data found" }, status: :not_found
        else
            @audio_recording.destroy
            render json: { "message": "deleted" }, status: :ok

        end
    end
  
    def show
        @audio_recording = AudioRecording.find_by(id: params[:id])
    
        if @audio_recording.nil?
            render json: { message: "Audio recording not found" }, status: :not_found
        elsif @audio_recording.audio_data.attached?
            render json: { 'data': @audio_recording, 'url': @audio_recording.audio_data.url }, status: :ok
        else
            render json: { message: "Audio data not attached to the recording" }, status: :not_found
        end
    end

    def update
        @audio_recording = AudioRecording.find(params[:id])

        if @audio_recording.update(audio_recording_params)
            render json: { message: "Recording updated successfully", user: @audio_recording }, status: :ok
        else
            render json: { errors: @audio_recording.errors }, status: :unprocessable_entity
        end

    end

    def create
    
        require "uri"
        require "net/http"

        url = URI(Rails.application.credentials.openai.url)

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(url)
        
        request["Authorization"] = "Bearer " + Rails.application.credentials.openai.access_key
        form_data = [['file', params['audio_data']],['model', 'whisper-1']]
        request.set_form form_data, 'multipart/form-data'
        response = https.request(request)
                              
        @audio_recording = AudioRecording.new
        
        # Check if the request was successful
        if response.is_a?(Net::HTTPSuccess)
            # Process the response body
            data = JSON.parse(response.body)
            @audio_recording.transcription = data["text"]
            puts response.body
        else
            puts "Request failed with status #{response.code}: #{response.message}"
            render json: {message: "Transcription service failed"}, status: :unprocessable_entity
            return
        end

        @audio_recording.audio_data.attach(params[:audio_data])
        @audio_recording.audio_url = @audio_recording.audio_data.url

        p @audio_recording.audio_data.url

        if @audio_recording.save
            render json: { message: "File uploaded successfully", transcription: @audio_recording.transcription, id: @audio_recording.id, url: @audio_recording.audio_data.url }, status: :created
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