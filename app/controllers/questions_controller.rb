# Админский контроллер, только для наполнения базы вопросов с помощью файлов
# определенного формата
# Создает новую игру, обновляет статус игры по ответам юзера, выдает подсказки
#
class QuestionsController < ApplicationController
  # Девайзовская проверка аутентификации
  before_action :authenticate_user!
  before_action :authorize_admin!

  def new
  end

  def create
    level = params[:questions_level].to_i
    q_file = params[:questions_file]

    if q_file.respond_to?(:readlines)
      file_lines = q_file.readlines
    elsif q_file.respond_to?(:path)
      file_lines = File.readlines(q_file.path)
    else
      redirect_to new_questions_path, alert: "Bad file_data: #{q_file.class.name}, #{q_file.inspect}"
      false
    end
    start_time = Time.now
    failed_count = create_questions_form_lines(file_lines, level)
    redirect_to new_questions_path,
                notice: "Уровень #{level}, обработано #{file_lines.size}," +
                  " создано #{file_lines.size - failed_count}," +
                  " время #{Time.at((Time.now - start_time).to_i).utc.strftime '%S.%L сек'}"
  end

  private

  def authorize_admin!
    redirect_to root_path unless current_user.is_admin
  end

  def create_questions_from_lines(lines, level)
    failed = 0
    ActiveRecord::Base.transaction do
      lines.each do |line|
        ar = line.split('|')
        q = Question.create(
          level: level,
          text: ar[0].squish,
          answer1: ar[1].squish,
          answer2: ar[2].squish,
          answer3: ar[3].squish,
          answer4: ar[4].squish
        )
        failed += 1 unless q.valid?
      end
    end

    failed
  end

end
