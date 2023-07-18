class CreateAudioRecordings < ActiveRecord::Migration[7.0]
  def change
    create_table :audio_recordings do |t|
      t.string :name
      t.string :audio_url
      t.text :transcription
      t.string :category
      t.text :comments

      t.timestamps
    end
  end
end
