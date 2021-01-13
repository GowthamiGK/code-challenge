module ApplicationHelper

  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def show_errors(object, field_name)
    if object.errors.any?
      if object.errors.messages[field_name].present?
        object.errors.messages[field_name].join(', ')
      end
    end
  end
  
end
