# test/controllers/audio_recordings_controller_test.rb
require 'test_helper'

class AudioRecordingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @audio_recording = audio_recordings(:one) # Assuming you have fixtures
    audio_file = fixture_file_upload('test.mp3', 'audio/mpeg')
    @audio_recording.audio_data.attach(audio_file)
  end

  test "should get index" do
    get api_v1_audio_recording_index_url, as: :json
    assert_response :success
  end

  test "should create audio_recording" do
    audio_file = fixture_file_upload('test.mp3', 'audio/mpeg')
    assert_difference('AudioRecording.count') do
      post api_v1_audio_recording_index_url, params: { audio_data: audio_file }, headers: { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'multipart/form-data' }
    end
    assert_response 201
  end

  test "should show audio_recording" do
    get api_v1_audio_recording_url(@audio_recording), as: :json
    assert_response :success
  end

  test "should get not found when trying to show non-existing audio_recording" do
    get api_v1_audio_recording_url(id: "non-existing-id"),  as: :json
    assert_response :not_found
  end

  test "should update audio_recording" do
    patch api_v1_audio_recording_url(@audio_recording), params: {  comments: 'updated comment' } , as: :json
    assert_response 200
  end

  test "should destroy audio_recording" do
    assert_difference('AudioRecording.count', -1) do
      delete api_v1_audio_recording_url(@audio_recording), as: :json
    end
    assert_response 200
  end

  test "should get not found when trying to delete non-existing audio recording" do
    delete api_v1_audio_recording_url(id: "non-existing-id")
    assert_response :not_found
  end
end