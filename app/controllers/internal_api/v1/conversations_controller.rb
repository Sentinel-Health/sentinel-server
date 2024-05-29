class InternalApi::V1::ConversationsController < InternalApi::V1::BaseController
  include ChatService

  before_action :find_conversation, only: [:show, :create_message]

  def index
    if params[:query].blank?
      conversations = Conversation.where(user_id: @current_user.id).order(last_activity_at: :desc)
    else
      conversations = Message.get_related_conversations(@current_user.id, params[:query], 0, {}, 100)
    end
    render json: conversations.map { |conversation| 
      ConversationJson.new(conversation).call
    }
  end

  def latest
    latest_conversation = Conversation.where(user_id: @current_user.id).order(last_activity_at: :desc).first

    unless latest_conversation.present?
      latest_conversation = Conversation.create!(user_id: @current_user.id)
    end

    render json: ConversationJson.new(latest_conversation).call
  end

  def show
    render json: ConversationJson.new(@conversation).call
  end

  def create
    initial_message = params[:message]
    if initial_message.present?
      @conversation = Conversation.create!(user_id: @current_user.id, last_activity_at: Time.now)
      new_message = {
        role: "user",
        content: initial_message
      }
      @conversation.messages.create!(
        role: new_message[:role],
        content: new_message[:content],
      )
      generate_chat_completion([new_message])

      send_new_message_notification
    else 
      @conversation = Conversation.create!(user_id: @current_user.id, last_activity_at: Time.now)
    end
    render json: ConversationJson.new(@conversation).call
  end

  def create_message
    new_message = params[:message]

    @conversation.messages.create!(
      role: new_message[:role],
      content: new_message[:content],
    )
    messages = @conversation.messages.order(created_at: :asc).map { |message|
      message_hash = {
        role: message.role,
        content: message.content,
      }

      message_hash[:function_call] = message.function_call if message.function_call.present?
      message_hash[:tool_calls] = message.tool_calls if message.tool_calls.present?
      message_hash[:tool_call_id] = message.tool_call_id if message.tool_call_id.present?
      message_hash[:name] = message.name if message.name.present?

      message_hash
    }

    existing_messages = Message.where(conversation_id: @conversation.id).order(created_at: :desc).to_a

    generate_chat_completion(messages)
    all_messages = Message.where(conversation_id: @conversation.id).order(created_at: :desc)

    new_messages = all_messages.reject { |message| existing_messages.any? { |existing_message| existing_message.id == message.id } }

    render json: { newMessages: new_messages.map { |message| MessageJson.new(message).call } }
  end

  private

  def find_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def generate_chat_completion(messages)
    system_prompt = default_chat_system_prompt(@current_user)
    system_message = {
      role: 'system',
      content: system_prompt,
    }

    # Put system message at the start of the messages array
    messages.unshift(system_message)
    chat_completion(
      @current_user.id,
      @conversation,
      messages,
      0.7,
      chat_functions(@current_user.id),
    )
  end

  def send_new_message_notification
    notification = UserNotification.create(
      user_id: @current_user.id,
      title: 'New message',
      body: 'You have a new message from Sentinel!',
      notification_type: :new_message,
      additional_data: {
        conversation_id: @conversation.id,
      }
    )
    SendUserNotificationsJob.perform_later(@current_user.id, notification.id) unless !@current_user.has_completed_onboarding
  end
end