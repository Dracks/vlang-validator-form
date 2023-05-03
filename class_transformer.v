module validator

pub struct ValueWithErrors[T, E] {
pub:
	value T
	errors E
}
/*
[inline]
pub fn (self ValueWithErrors[T, []IError]) has_errors() bool{
	return self.errors.len>0
}
*/
[inline]
pub fn (self ValueWithErrors[T, map[string][]IError]) has_errors() bool{
	return self.errors.len>0
}

pub enum FieldErrorEnum {
	required
	min_length
	max_length
	min
	max
}


// type ValidateRet[T] = ValueWithErrors[T, []IError]
// type TransformAndValidateRet[T] = T | ValueWithErrors[T, map[string][]IError]

pub fn transform_and_validate[T](data map[string]string) ValueWithErrors[T, map[string][]IError] {
	new_object := T{}
	mut errors := map[string][]IError{}
	$for field in T.fields {
		$if field.typ is string {
			raw_data := get_string(data, field.name, new_object.$(field.name))
			data_with_errors := validate_string(raw_data, field.attrs)
			
			new_object.$(field.name) = data_with_errors.value
			if data_with_errors.errors.len>0 {
				errors[field.name] = data_with_errors.errors
			}
		} $else $if field.typ is int {
			raw_data := get_int(data, field.name, new_object.$(field.name))
			data_with_errors := validate_int(raw_data, field.attrs)
			new_object.$(field.name) = data_with_errors.value
			if data_with_errors.errors.len>0 {
				errors[field.name] = data_with_errors.errors
			}
		} $else $if field.typ is bool {
			raw_data := get_bool(data, field.name, new_object.$(field.name))
			new_object.$(field.name) = validate_bool(raw_data, field.attrs) or {
				errors[field.name] = [err]
				false
			}
		}
	}
	return ValueWithErrors[T, map[string][]IError]{
		errors: errors,
		value: new_object
	}
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

fn validate_string(data ?string, attrs []string) ValueWithErrors[string, []IError] {
	str := check_required(data, attrs, '') or { return ValueWithErrors{value: "", errors: [err]} }
	mut errors := []IError{}
	for attr in attrs {
		if validator := parse_string_attr[string](attr) {
			if error := validator(str) {
				errors << error
			}
		}
	}
	return ValueWithErrors{
		value: str,
		errors: errors
	}
}

fn validate_int(data ?int, attrs []string) ValueWithErrors[int, []IError] {
	number := check_required(data, attrs, 0) or { return ValueWithErrors[int, []IError]{errors: [err]} }
	mut errors := []IError{}
	for attr in attrs {
		if validator := parse_number_attr[int](attr) {
			if error := validator(number) {
				errors << error
			}
		}
	}
	return ValueWithErrors{
		value: number,
		errors: errors
	}
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
