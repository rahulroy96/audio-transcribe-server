class Api::V1::AudioRecordingController < ApplicationController
    before_action do
        ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
    end

    def index
        Rails.logger.info 'Processing index action'
        @audio_recordings = AudioRecording.order(created_at: :desc).paginate(page: params[:page], per_page: 15)
    
        @audio_recordings.each do |audio_recording|
            if audio_recording.audio_data.attached?
                audio_recording.audio_url = audio_recording.audio_data.url
            end
        end   

        total_pages = @audio_recordings.total_pages
    
        response.headers['X-Total-Pages'] = total_pages.to_s
        render json: @audio_recordings, status: :ok
        Rails.logger.info 'Index action processed successfully'
    end

    def destroy
        Rails.logger.info 'Processing destroy action'
        @audio_recording = AudioRecording.find_by(id: params[:id])
    
        if @audio_recording.nil?
            # If the audio recording is nill, return not found
            Rails.logger.info("Attempted to delete audio recording with id #{params[:id]}, but no recording was found")
            render json: { "message": "no data found" }, status: :not_found
        else
            # Delete the recording and return status ok
            @audio_recording.destroy
            Rails.logger.info("Audio recording with id #{params[:id]} was successfully deleted")
            render json: { "message": "deleted" }, status: :ok

        end
    end
  
    def show
        @audio_recording = AudioRecording.find_by(id: params[:id])
    
        if @audio_recording.nil?
            # If the audio recording is nill, return not found
            Rails.logger.info("Audio recording with id #{params[:id]} not found")
            render json: { message: "Audio recording not found" }, status: :not_found
        elsif @audio_recording.audio_data.attached?
            Rails.logger.info("Audio recording with id #{params[:id]} found and has audio data attached")
            @audio_recording.audio_url = @audio_recording.audio_data.url
            render json: @audio_recording, status: :ok
        else
            Rails.logger.info("Audio recording with id #{params[:id]} found but no audio data attached")
            render json: { message: "Audio data not attached to the recording" }, status: :not_found
        end
    end

    def update
        @audio_recording = AudioRecording.find_by(id: params[:id])

        if @audio_recording.nil?
            Rails.logger.info("Audio recording with id #{params[:id]} not found")
            render json: { message: "Audio recording not found" }, status: :not_found
        elsif @audio_recording.update(audio_recording_params)
            Rails.logger.info("Audio recording with id #{params[:id]} was successfully updated")
            render json: { message: "Recording updated successfully", data: @audio_recording }, status: :ok
        else
            Rails.logger.error("Audio recording with id #{params[:id]} update failed with errors: #{@audio_recording.errors.full_messages.join(', ')}")
            render json: { errors: @audio_recording.errors }, status: :unprocessable_entity
        end

    end

    def create
        transcription = TranscriptionService.new(params['audio_data']).transcribe

        return render json: {message: "Transcription service failed"}, status: :unprocessable_entity unless transcription

        @audio_recording = AudioRecording.new(transcription: transcription)

        @audio_recording.audio_data.attach(params[:audio_data])

        @audio_recording.audio_url = @audio_recording.audio_data.url

        if @audio_recording.save
            Rails.logger.info "The audio recording transcribed successfully and returned 201"
            render json: { message: "File uploaded successfully", data: @audio_recording  }, status: :created
        else
            Rails.logger.error "Error while trying to save the audio recording #{@audio_recording.message}"
            render json: @audio_recording.errors, status: :unprocessable_entity
        end
    end

    private
    def audio_recording_params
      params.permit(:name, :category, :audio_url, :transcription, :comments)
    end
end


# The transcription service used to convert the audio to text
# Currrently we are using open ai whisper for the same.
class TranscriptionService
    def initialize(audio_data)
        @audio_data = audio_data
    end

    def transcribe
        require "uri"
        require "net/http"

        Rails.logger.info "Starting to transcribe the Audio data"

        url = URI(Rails.application.credentials.openai.url)

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(url)
        
        request["Authorization"] = "Bearer " + Rails.application.credentials.openai.access_key
        form_data = [['file', @audio_data],['model', 'whisper-1']]
        request.set_form form_data, 'multipart/form-data'
        response = https.request(request)
                              
        # Check if the request was successful
        if response.is_a?(Net::HTTPSuccess)
            # Process the response body
            data = JSON.parse(response.body)
            Rails.logger.info "Audio data transcribed successfully"
            return data["text"]
        else
            Rails.logger.error "Request failed with status #{response.code}: #{response.message}"
            return nil
        end
    rescue => e
        Rails.logger.error "Error: #{e.message}"
        return nil
    end
end
