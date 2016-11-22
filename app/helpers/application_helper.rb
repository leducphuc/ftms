module ApplicationHelper
  include SessionsHelper

  def full_title page_title = ""
    base_title = t "staticpages.framgia"
    page_title.present? ? "#{page_title} | #{base_title}" : base_title
  end

  def flash_class level
    case level
    when :notice then "alert-info"
    when :error, :failed then "alert-error"
    when :alert then "alert-warning"
    when :success then "alert-success"
    end
  end

  def flash_message flash_type, *params
    if params.empty?
      t "flashs.messages.#{flash_type}", model_name: controller_name.classify
    else
      t "flashs.messages.#{flash_type}",
        models_name: params[0].join(", ") unless params[0].empty?
    end
  end

  def link_to_remove_fields name, f
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields name, f, association
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def link_to_function name, function, html_options = {}
    message = t "message-link-to-function"
    ActiveSupport::Deprecation.warn message
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'
    content_tag :a, name, html_options.merge(href: href, onclick: onclick)
  end

  def tab_active tab_name, current_tab
    current_tab == tab_name ? "active" : nil
  end

  def member_list members
    members.map {|member| link_to member.name, member}.join(", ").html_safe
  end

  def select_profile_field target, target_array, builder, klass = ""
    builder.select "#{target}_id".to_sym,
      options_for_select(target_array.collect {|t|
      [t.name, t.id ]}, builder.object.send("#{target}_id")),
      {include_blank: true}, class: "form-control #{klass}"
  end

  def avatar_user_tag user, class_name, avatar_size
    image_tag user.avatar_url ? user.avatar_url : "profile.png",
      class: class_name.to_sym, size: avatar_size
  end

  def set_image object, size = Settings.image_size_100, class_name = "img-circle"
    image_tag object.image_url ? object.image_url : "no_image.gif", size: size, class: class_name
  end

  def image_course_tag course, language, size = Settings.image_size_100, class_name = "img-circle"
    image_tag course.image_url ? course.image_url : "#{language.downcase}.png", size: size,
      class: class_name
  end

  def image_object chat_room
    if chat_room.class.name == "User"
      avatar_user_tag chat_room, "img-circle",
        Settings.image_size_40
    elsif chat_room.class.name == "Course"
      image_course_tag chat_room, chat_room.programming_language_name,
        Settings.image_size_40
    end
  end

  def set_color_status status
    "#{status}-color"
  end

  def set_background_color_status status
    "#{status}-background-color"
  end

  def set_border_status status
    "#{status}-border-color"
  end

  def add_breadcrumb_path resource
    add_breadcrumb t("breadcrumbs.#{resource}.all"),
      "#{@namespace}_#{resource}_path".to_sym
  end

  def add_breadcrumb_index resource
    add_breadcrumb t "breadcrumbs.#{resource}.all"
  end

  def add_breadcrumb_new resource
    add_breadcrumb t "breadcrumbs.#{resource}.new"
  end

  def add_breadcrumb_edit resource
    add_breadcrumb t "breadcrumbs.#{resource}.edit"
  end

  def add_breadcrumb_subject_task_masters
    add_breadcrumb t("breadcrumbs.subjects.task_masters")
  end

  def add_breadcrumb_subject_new_task
    add_breadcrumb t("breadcrumbs.subjects.new_task")
  end

  def add_breadcrumb_role_allocate_permissions
    add_breadcrumb t "breadcrumbs.roles.allocate_permissions"
  end

  def i18n_enum model_name, enum
    enum = enum.to_s.pluralize
    model_name = model_name.to_s
    model_name.classify.constantize.public_send(enum).keys.map do |key|
      OpenStruct.new key: key, value: I18n.t("#{model_name.pluralize}.#{enum}.#{key}")
    end.flatten
  end

  def percentage_format number
    number_to_percentage number, precision: 1, strip_insignificant_zeros: true
  end

  def chat_type room
    chat_room = room.class.name
    chat_room == User.name ? Conversation.name : chat_room
  end

  def allow_render_message message, active_room
    message.chat_room_type == Conversation.name && active_room.to_i != current_user.id
  end

  def unseen_number current_user, chat_room
    chat_room = Conversation.existing_conversation(
      chat_room.id, current_user.id).first if chat_room.class.name == "User"

    count = 0
    count = chat_room.messages.unread_by(current_user).size if chat_room
    count > 0 ? count : nil
  end

  def class_body name
    name == "static_pages" || name == "sessions" || name == "passwords" ?
      "body_home" : "container body-wrapper-content"
  end

  def progressbar_color percent
    if percent < 40
      "progress-bar-info"
    elsif percent < 60
      "progress-bar-success"
    elsif percent < 80
      "progress-bar-warning"
    else
      "progress-bar-danger"
    end
  end

  def task_color status
    if status == "in_progress"
      "text-blue"
    elsif status == "finish"
      "text-muted"
    end
  end

  def the_rest_member user_subjects
    user_subjects.progress.size - Settings.number_member_show
  end

  ["set_background_color_", ""].each do |prefix|
    define_method "#{prefix}status_subject" do |user_subjects|
      if user_subjects.size == user_subjects.init.size
        prefix.blank? ? t("user_subjects.init") : "init-background-color"
      elsif user_subjects.size > 0 && user_subjects.size == user_subjects
        .finish.size
        prefix.blank? ? t("user_subjects.finished") :
          "finished-background-color"
      else
        prefix.blank? ? t("user_subjects.in_progress") :
          "in_progress-background-color"
      end
    end
  end

  def data_finish_task data
    data.blank? || data.values.sum == 0 ? false : true
  end

  def i18n_pluralize number, word
    I18n.locale == :en ? pluralize(number, t("#{word}")) : "#{number} #{I18n.t word}"
  end

  def filter_selector_name element, value_field
    return if element.nil?
    if element.try(value_field).kind_of?(Date) || element.kind_of?(Date)
      return (element.try(value_field)
        .strftime(t "date.formats.default") rescue element.strftime(t "date.formats.default"))
    end
    element.try(value_field).strip rescue element.to_s.strip
  end

  def filter_title
    @filter_service.is_on? ? t("filters.btn_off") : t("filters.btn_on")
  end

  def color_result exam
    if exam.score < exam.user_subject.subject.subject_detail_min_score_to_pass
      set_background_color_status "fail"
    else
      set_background_color_status "pass"
    end
  end

  def status_result exam
    if exam.score < exam.user_subject.subject.subject_detail_min_score_to_pass
      t "status.fail"
    else
      t "status.pass"
    end
  end

  def remaining_time exam
    if exam.init? || exam.testing?
      time_remaining = (exam.duration.minutes - (Time.zone.now - exam.started_at)).to_i
      return time_remaining if time_remaining > 0
    end
    0
  end

  def percent_of_question percent_of_questions
    if percent_of_questions.blank?
      Settings.exams.percent_question.to_s
    else
      percent_of_questions
    end
  end

  def footer_not_show controller_name
    controller_name == "sessions" || controller_name == "passwords"
  end

  def load_user_roles user
    Role.joins(:users).where users: {id: user.id}
  end

  def set_background_answer answer, result
    if answer == result.answer && !answer.is_correct?
      "style=background-color:red;"
    end
  end

  def namespace
    @namespace
  end

  def checked? params, type, object_id
    !params.has_key?(type) || params[type].include?(object_id)
  end

  def allowed_file
    Settings.import.file_types.join ", "
  end
end
