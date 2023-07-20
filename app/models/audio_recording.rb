class AudioRecording < ApplicationRecord
    has_one_attached :audio_data

    validate :validate_audio_data
end

def validate_audio_data
    p "cotent type is "
    p audio_data.content_type
    return unless audio_data.attached?
    unless audio_data.content_type.in?(["audio/mp3", "audio/mp4", "audio/mpga", "audio/mpeg", "audio/m4a", "audio/wav", "audio/webm"])
        errors.add(:audio_data, "The audio file type must be one of mp3, mp4, mpeg, mpga, m4a, wav, and webm")
    end 

    unless audio_data.blob.byte_size <= 5.megabyte
        errors.add(:audio_data, "is too big")
    end
end

