class AudioRecording < ApplicationRecord
    has_one_attached :audio_data

    validate :validate_audio_data
end

def validate_audio_data
    Rails.logger.info("Audio data content type: #{audio_data.content_type}")
    return unless audio_data.attached?
    # Check the content type of the uploaded audio file, if it is not a supported type return can't process
    unless audio_data.content_type.in?(["audio/mp3", "audio/mp4", "audio/mpga", 
        "audio/mpeg", "audio/m4a", "audio/wav", "audio/webm", "audio/x-wav"])
        Rails.logger.error("Invalid content type: #{audio_data.content_type}")
        errors.add(:audio_data, "The audio file type must be one of mp3, mp4, mpeg, mpga, m4a, wav, and webm")
    end 
    # Don't allow too big recordings to be uploaded, prevents s3 from getting filled up
    unless audio_data.blob.byte_size <= 5.megabyte
        Rails.logger.error("File size is too large: #{audio_data.blob.byte_size / 1.megabyte} megabytes")
        errors.add(:audio_data, "is too big")
    end
end

