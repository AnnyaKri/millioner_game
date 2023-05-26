# Админский контроллер, только для наполнения базы вопросов с помощью файлов
# определенного формата
# Создает новую игру, обновляет статус игры по ответам юзера, выдает подсказки
#
class QuestionsController < ApplicationController
  # Девайзовская проверка аутентификации
  before_action :authenticate_user!

  # Нельзя создавать игру, если не закончена предыдущая
  before_action :goto_game_in_progress!, only: %i[create]

  # Загружаем игру из базы для текущего юзера
  before_action :set_game, except: %i[create]

  # Если игра завершена, отправляем юзера на его профиль, где он
  # видит статистику своих игр.
  before_action :redirect_from_finished_game!, except: %i[create]

  def show
    @game_question = @game.current_game_question
  end

  def create
    begin
      # Создаем игру для залогиненного юзера
      @game = Game.create_game_for_user!(current_user)

      # Отправляемся на страницу игры
      redirect_to game_path(@game), notice: I18n.t(
        'controllers.games.game_created',
        created_at: @game.created_at
      )
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => ex
      # Если ошибка создания игры
      Rails.logger.error("Error creating game for user #{current_user.id}, " \
                         "msg = #{ex}. #{ex.backtrace}")

      # Отправляемся назад с сообщением
      redirect_to :back, alert: I18n.t('controllers.games.game_not_created')
    end
  end

  # Действие answer принимает ответ на вопрос
  # Единственный обязательный параметр — params[:letter]
  # Это буква, которую выбрал игрок.
  def answer
    # Выясняем у игры, правильно ли ответили
    @answer_is_correct = @game.answer_current_question!(params[:letter])
    @game_question = @game.current_game_question

    unless @answer_is_correct
      # Если ответили неправильно, отправляем юзера на профиль с сообщением
      flash[:alert] = I18n.t(
        'controllers.games.bad_answer',
        answer: @game_question.correct_answer,
        prize: view_context.number_to_currency(@game.prize)
      )
    end

    if @game.finished?
      # Если игра закончилась, отправляем юзера на свой профиль
      redirect_to user_path(current_user)
    else
      # Иначе — обратно на экран игры
      redirect_to game_path(@game)
    end
  end

  # Действие take_money вызывается из шаблона, когда пользователь нажимает кнопку
  # «Взять деньги». Параметров нет, т.к. вся необходимая информация есть в базе.
  def take_money
    # Заканчиваем игру
    @game.take_money!

    # Отправляем пользователя на профиль с сообщение о выигрыше
    redirect_to user_path(current_user), flash: {
      warning: I18n.t(
        'controllers.games.game_finished',
        prize: view_context.number_to_currency(@game.prize)
      )
    }
  end

  private

  def redirect_from_finished_game!
    if @game.finished?
      redirect_to user_path(current_user), alert: I18n.t(
        'controllers.games.game_closed',
        game_id: @game.id
      )
    end
  end

  def goto_game_in_progress!
    game_in_progress = current_user.games.in_progress.first

    unless game_in_progress.blank?
      redirect_to game_path(game_in_progress), alert: I18n.t(
        'controllers.games.game_not_finished'
      )
    end
  end

  def set_game
    @game = current_user.games.find_by(id: params[:id])

    if @game.blank?
      redirect_to root_path, alert: I18n.t(
        'controllers.games.not_your_game'
      )
    end
  end
end
