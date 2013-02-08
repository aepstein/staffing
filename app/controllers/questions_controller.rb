class QuestionsController < ApplicationController
  expose( :quiz ) { Quiz.find params[:quiz_id] if params[:quiz] }
  expose( :context ) { quiz }
  expose :q_scope do
    scope = quiz.questions
    scope ||= Question.scoped
    scope.scoped
  end
  expose :q do
    q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] )
  end
  expose( :questions ) { q.result.ordered.page(params[:page]) }
  expose :question
  filter_resource_access

  # POST /questions
  # POST /questions.xml
  def create
    respond_to do |format|
      if question.save
        format.html { redirect_to( question, flash: { success: 'Question created.' } ) }
        format.xml  { render xml: question, status: :created, location: question }
      else
        format.html { render action: "new" }
        format.xml  { render xml: question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |format|
      if question.save
        format.html { redirect_to( question, flash: { success: 'Question updated.' } ) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    question.destroy

    respond_to do |format|
      format.html { redirect_to( questions_url, flash: { success: "Question destroyed." } ) }
      format.xml  { head :ok }
    end
  end
end

