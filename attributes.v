module validator

type Validator[T] = fn (data T) ?FieldError

type IntValidator = fn (data int) ?FieldError

struct AttribHelper {
pub:
	key    string   [required]
	params []string [required]
}

[inline]
fn (attr AttribHelper) get_param(index int, err_string string) string {
	str := attr.params[index] or { panic(err_string) }
	return str.trim(' ')
}

[inline]
fn (attr AttribHelper) get_int_param(index int, err_string string) int {
	str := attr.get_param(index, err_string)
	number := str.int()
	if number != 0 || str != '0' {
		return number
	} else {
		panic(err_string)
	}
}

fn attr_helper(attr string) AttribHelper {
	attr_split := attr.split(':')
	return AttribHelper{
		key: attr_split.first()
		params: attr_split[1..]
	}
}

// need to use T here, otherwise the number cannot use T
fn parse_string_attr[T](attr string) ?Validator[T] {
	parsed_attr := attr_helper(attr)
	match parsed_attr.key {
		'min_length' {
			length := parsed_attr.get_int_param(0, 'no valid attribute config in min_length attribute, usage: min_length:123')
			return fn [length] (str string) ?FieldError {
				if str.len < length {
					return error(FieldErrorEnum.min_length, 'minimum (${length}) length not valid, found "${str}" (${str.len}) ')
				}
				return none
			}
		}
		'max_length' {
			length := parsed_attr.get_int_param(0, 'no valid attribute config in max_length attribute, usage: max_length:123')
			return fn [length] (str string) ?FieldError {
				if str.len > length {
					return error(FieldErrorEnum.max_length, 'maximum (${length}) length not valid, found "${str}" (${str.len})')
				}

				return none
			}
		}
		else {}
	}
	return none
}

fn parse_number_attr[T](attr string) ?Validator[T] {
	parsed_attr := attr_helper(attr)
	match parsed_attr.key {
		'min' {
			value := parsed_attr.get_int_param(0, 'no valid attribute config in min attribute, usage: min:3')
			return fn [value] [T](number T) ?FieldError {
				if number < value {
					return error(FieldErrorEnum.min, 'minimum (${value}) value not valid, found "${number}" ')
				}
				return none
			}
		}
		'max' {
			value := parsed_attr.get_int_param(0, 'no valid attribute config in max attribute, usage: max:6')
			return fn [value] [T](number T) ?FieldError {
				if number > value {
					return error(FieldErrorEnum.max, 'maximum (${value}) value not valid, found "${number}"')
				}
				return none
			}
		}
		else {}
	}
	return none
}
