# IMPORTS
import re
import numpy as np
# CONSTANTS
INSTRUCTION_SIZE = 32
REGISTER_ADRESS_SIZE = 3
FUNCTION_SIZE = 5
OPERATION_SIZE = 5
IMM_OFFEST_SIZE = 16
MEMORY_UNIT_SIZE = 16
MEMORY_NUMBER_OF_UNITS = 2 ** 20
ONE_OPERANDS = ['nop', 'setc', 'clrc', 'not', 'inc', 'dec', 'out', 'in']
TWO_OPERANDS = ['mov', 'add', 'sub', 'and', 'or', 'shl', 'shr']
MEMORY_AND_IMMEDIATE = ['push', 'pop', 'std', 'ldd', 'ldm', 'iadd']
BRANCH = ['jz', 'jn', 'jc', 'jmp', 'call', 'ret']


def convert_to_binary(decimal, size):
    binary = bin(decimal)[2:]
    return '0' * (size - len(binary)) + binary


function_map = {}
for i, op in enumerate(ONE_OPERANDS):
    function_map[op] = convert_to_binary(i, FUNCTION_SIZE)
two_operands_operation_map = {}
for i, op in enumerate(TWO_OPERANDS):
    two_operands_operation_map[op] = convert_to_binary(i+1, OPERATION_SIZE)
memory_immediate_operation_map = {}
for i, op in enumerate(MEMORY_AND_IMMEDIATE):
    memory_immediate_operation_map[op] = '01' + convert_to_binary(
        i, 3) if op not in ['ldm', 'iadd'] else '011' + convert_to_binary(i - 4 + 2, 2)


def get_reg_number(register_string):
    return convert_to_binary(int(register_string[1:], 16), REGISTER_ADRESS_SIZE)


def convert_one_operand(instruction):
    insruction_bits = '0' * 5
    insruction_bits += get_reg_number(instruction[1]) if len(
        instruction) > 1 else '0' * REGISTER_ADRESS_SIZE
    insruction_bits += '0' * REGISTER_ADRESS_SIZE
    insruction_bits += function_map[instruction[0]]
    return insruction_bits


def convert_two_opreand(instruction):
    insruction_bits = two_operands_operation_map[instruction[0]]
    insruction_bits += get_reg_number(instruction[2]) if instruction[0] not in [
        'shl', 'shr'] else get_reg_number(instruction[1])
    insruction_bits += get_reg_number(instruction[1]) if instruction[0] not in [
        'shl', 'shr'] else '0' * REGISTER_ADRESS_SIZE
    insruction_bits += '0' * FUNCTION_SIZE if instruction[0] not in [
        'shl', 'shr'] else convert_to_binary(int(instruction[2], 16), FUNCTION_SIZE)
    return insruction_bits


def convert_memory_immediate(instruction):
    insruction_bits = memory_immediate_operation_map[instruction[0]]
    insruction_bits += get_reg_number(instruction[1]) if instruction[0] in [
        'push', 'pop', 'ldm', 'iadd'] else get_reg_number(instruction[3])
    insruction_bits += '0' * REGISTER_ADRESS_SIZE if instruction[0] in [
        'push', 'pop', 'ldm', 'iadd'] else get_reg_number(instruction[1])
    insruction_bits += '0' * IMM_OFFEST_SIZE if instruction[0] in [
        'push', 'pop'] else convert_to_binary(int(instruction[2], 16), IMM_OFFEST_SIZE)
    insruction_bits += '0' * (INSTRUCTION_SIZE - len(insruction_bits))
    return insruction_bits


def parse_instruction(instruction):
    instruction = re.sub(r'[,()]', ' ', instruction)
    instruction = re.split(r'\s+', instruction.strip())
    return instruction


def convert_instruction(instruction):
    instruction = parse_instruction(instruction.lower())
    return convert_one_operand(instruction) if instruction[0] in ONE_OPERANDS else convert_two_opreand(instruction) if instruction[0] in TWO_OPERANDS else convert_memory_immediate(instruction)


def print_16_bits(instruction):
    print(instruction[:5], instruction[5:8],
          instruction[8:11], instruction[11:])


def print_32_bits(instruction):
    print(instruction[:5], instruction[5:8],
          instruction[8:11], instruction[11:27], instruction[27:])


def chech_print(instruction):
    if len(instruction) == 32:
        print_32_bits(instruction)
    elif len(instruction) == 16:
        print_16_bits(instruction)
    else:
        print('Error in converter')


def is_org(string):
    return string.lower()[:4] == '.org'


def convert_file(file):
    file = open(file, 'r')
    binary_memory = np.full(MEMORY_NUMBER_OF_UNITS,
                            fill_value='0' * MEMORY_UNIT_SIZE)
    org_value = 0
    for line in file:
        comment_split = line.strip().split('#')
        if comment_split[0] != '':
            instruction_string = comment_split[0]
            if is_org(instruction_string):
                org_value = int(instruction_string[4:], 16)
            else:
                try:
                    binary_memory[org_value] = convert_to_binary(
                        int(instruction_string, 16), MEMORY_UNIT_SIZE)
                    org_value += 1
                except:
                    op_code = convert_instruction(instruction_string)
                    if len(op_code) == 32:
                        binary_memory[org_value] = op_code[:16]
                        org_value += 1
                        binary_memory[org_value] = op_code[16:]
                        org_value += 1
                    elif len(op_code) == 16:
                        binary_memory[org_value] = op_code
                        org_value += 1
                    else:
                        raise('ERR: unexpected opeartion code length: ' +
                              str(len(op_code)))
    file.close()
    return binary_memory
