import utils as u

if __name__ == '__main__':
    input_file_name = input('Enter input file name: ')
    print('reading from: '+'instructions/'+input_file_name+'.asm')
    output_file_name = input('Enter input file name: ')
    output_file = open('../instructions/'+output_file_name+'.txt', 'w')
    for i, instruction in enumerate(u.convert_file('../instructions/'+input_file_name+'.asm')):
        output_file.write(instruction + ('\n' if i !=
                                         u.MEMORY_NUMBER_OF_UNITS-1 else ''))
    output_file.close()
    print('File converted successfully and saved at: ' +
          'instructions/'+output_file_name+'.txt')
