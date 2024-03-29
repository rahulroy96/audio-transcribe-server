# README

* Ruby version: 3.2.2

* Database creation 
- Uses Postgres as the database 
- Update the DBUSER, DBPASS, DBHOST, and DBNAME values in the credentials file (Use EDITOR=vim rails credentials:edit command to edit)
- Now the required db can be created by running rake db:migrate.

* Database initialization: Run rake db:seed

* How to run: Run rails s

# Implementation Details
The Frontend calls the API with audio data. The audio data gets stored in S3 and an external call is made to the Open AI transcription service. The s3 link along with the transcription received from the service is stored in the Postgres DB. We also have endpoints defined for getting all the recordings, getting particular recordings, deleting a recording, and also to update the recordings. Rails active storage is used for attaching the audio file to the AudioRecording model. The will_paginate package is used to paginate the response while fetching the list of recordings from db.

## Architecture

![architecture](https://github.com/rahulroy96/audio-transcribe-server/assets/20977374/77eb0432-eb95-4625-b1f7-6c8789cab6c1)


* ...

# AudioRecording API Endpoints

## GET /api/v1/audio_recordings
List all audio recordings, ordered by creation date in descending order, 10 per page.

### Response Headers
- `X-Total-Pages`: The total number of pages.

### Response Body
An array of audio recording objects.

---

## GET /api/v1/audio_recordings/:id
Get a specific audio recording by its ID.

### Path Parameters
- `id`: The ID of the audio recording.

### Response Body
A single audio recording object.

---

## POST /api/v1/audio_recordings
Create a new audio recording.

### Request Body
- `audio_data`: The audio file to upload and transcribe.

### Response Body
An object containing the ID of the newly created audio recording, the transcription of the audio file, and the URL of the uploaded audio file.

---

## PATCH /api/v1/audio_recordings/:id
Update a specific audio recording by its ID.

### Path Parameters
- `id`: The ID of the audio recording.

### Request Body
- `name`: The new name for the audio recording.
- `category`: The new category for the audio recording.
- `audio_url`: The new URL for the audio file of the audio recording.
- `transcription`: The new transcription for the audio recording.
- `comments`: The new comments for the audio recording.

### Response Body
An object containing the updated audio recording.

---

## DELETE /api/v1/audio_recordings/:id
Delete a specific audio recording by its ID.

### Path Parameters
- `id`: The ID of the audio recording.

### Response Body
A message indicating that the deletion was successful.

