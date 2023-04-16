module validator

/*
interface IError {
	code() int
	msg() string
}
*/

pub enum FieldErrorEnum {
	required
	min_length
	max_length
	min
	max
}

struct FieldError {
	int_code    FieldErrorEnum
	int_message string
}

fn (err FieldError) code() int {
	return int(err.int_code)
}

fn (err FieldError) msg() string {
	return err.int_message
}

[inline]
fn error(code FieldErrorEnum, msg string) FieldError {
	return FieldError{
		int_code: code
		int_message: msg
	}
}

type ValidateRet[T] = T | []IError
type TransformAndValidateRet[T] = T | map[string][]IError

pub fn transform_and_validate[T](data map[string]string) TransformAndValidateRet[T] {
	new_config := T{}
	mut errors := map[string][]IError{}
	$for field in T.fields {
		$if field.typ is string {
			raw_data := get_string(data, field.name, new_config.$(field.name))
			data_or_errors := validate_string(raw_data, field.attrs)
			if data_or_errors is string {
				new_config.$(field.name) = data_or_errors
			} else if data_or_errors is []IError {
				errors[field.name] = data_or_errors
			}
		} $else $if field.typ is int {
			raw_data := get_int(data, field.name, new_config.$(field.name))
			data_or_errors := validate_int(raw_data, field.attrs)
			if data_or_errors is int {
				new_config.$(field.name) = data_or_errors
			} else if data_or_errors is []IError {
				errors[field.name] = data_or_errors
			}
		} $else $if field.typ is bool {
			raw_data := get_bool(data, field.name, new_config.$(field.name))
			new_config.$(field.name) = validate_bool(raw_data, field.attrs) or {
				errors[field.name] = [err]
				false
			}
		}
	}
	if errors.keys().len > 0 {
		return errors
	}
	return new_config
}

[inline]
fn check_required[T](data ?T, attrs []string, def T) !T {
	if d := data {
		return d
	} else {
		if 'req' in attrs {
			return error(.required, 'Field is required')
		} else {
			return def
		}
	}
}

fn validate_string(data ?string, attrs []string) ValidateRet[string] {
	str := check_required(data, attrs, '') or { return [err] }
	mut errors := []IError{}
	for attr in attrs {
		if validator := parse_string_attr[string](attr) {
			if error := validator(str) {
				errors << error
			}
		}
	}
	if errors.len > 0 {
		return errors
	}

	return str
}

fn validate_int(data ?int, attrs []string) ValidateRet[int] {
	number := check_required(data, attrs, 0) or { return [err] }
	mut errors := []IError{}
	for attr in attrs {
		if validator := parse_number_attr[int](attr) {
			if error := validator(number) {
				errors << error
			}
		}
	}
	if errors.len > 0 {
		return errors
	}

	return number
}

fn validate_bool(data ?bool, attrs []string) !bool {
	return check_required(data, attrs, false)
}

fn get_string(data map[string]string, field_name string, original ?string) ?string {
	var_name := field_name
	if var_name in data {
		return data[var_name]
	}
	if original? != '' {
		return original
	} else {
		return none
	}
}

fn get_int(data map[string]string, field string, original ?int) ?int {
	if str := get_string(data, field, none) {
		return str.trim(' ').int()
	}
	if original? != 0 {
		return original
	} else {
		return none
	}
}

fn get_bool(data map[string]string, field string, original ?bool) ?bool {
	if d := get_string(data, field, none) {
		return d.trim(' ').bool()
	}
	return original
}
