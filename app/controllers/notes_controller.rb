class NotesController < ApplicationController
  before_action :set_note, only: [ :update, :destroy ]
  respond_to :js

  def create
    @note = Note.new(notes_params)
    submission = @note.submission
    unless submission.notes.any?
      Notification.create(task: submission.task, user: submission.student.user, event_type: :added_comments)
      UserMailer.new_notes_notify(submission).deliver 
    end

    submission.task.accepted_partially!
    @note.save
  end

  def update
    @note.update(notes_params)
  end

  def destroy
    @task = @note.submission.task
    @note.destroy

    unless @task.notes.any?
      @task.waiting!
    end
  end

  private
    def notes_params
      params.require(:note).permit(:text, :submission_id, :fixed)
    end

    def set_note
      @note = Note.find(params[:id])
    end
end
