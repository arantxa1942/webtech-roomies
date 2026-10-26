module ApplicationHelper
  def invalid_class(record, attribute)
    record.errors[attribute].any? ? "is-invalid" : ""
  end

  def field_errors(record, attribute)
    return if record.errors[attribute].empty?

    tag.div(record.errors[attribute].to_sentence, class: "invalid-feedback d-block")
  end
end
