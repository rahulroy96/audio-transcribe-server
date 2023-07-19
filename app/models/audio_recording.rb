class AudioRecording < ApplicationRecord
    has_one_attached :audio_data

    validate :validate_audio_data
end

def validate_audio_data
    p "cotent type is "
    p audio_data.content_type
    return unless audio_data.attached?
    unless audio_data.content_type.in?(["audio/ogg", "video/quicktime"])
        errors.add(:audio_data, "must be an audio file")
    end 

    unless audio_data.blob.byte_size <= 5.megabyte
        errors.add(:audio_data, "is too big")
    end
end

