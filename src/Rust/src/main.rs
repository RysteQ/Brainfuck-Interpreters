use std::env::args;
use std::fs;
use std::io;

fn main() {
    let args: Vec<String> = args().collect::<Vec<String>>();

    if args.len() != 2 {
        println!("Please enter an input file");
        std::process::exit(-1);
    }

    let program_data: String = read_file(args[1].clone());
    brainfuck(program_data);
}

fn read_file(input_file: String) -> String {
    fs::read_to_string(input_file).expect("Error reading file")
}

fn read_console_input() -> u8 {
    let mut to_return: &mut String = &mut String::new();
    io::stdin().read_line(&mut to_return).expect("Error reading console input");

    to_return.chars().nth(0).unwrap() as u8
}

fn brainfuck(program_data: String) {
    let mut index: usize = 0;
    let mut memory: [u8; 30000] = [0; 30000];
    let mut memory_index: usize = 0;

    let mut opening_brackets: i32 = 0;
    let mut closing_brackets: i32 = 0;

    while index < program_data.len() {
        match program_data.chars().nth(index).unwrap() {
            '+' => {
                if memory[memory_index] == 255 {
                    memory[memory_index] = 0;
                } else {
                    memory[memory_index] += 1
                }
            }
            
            '-' => {
                if memory[memory_index] == 0 {
                    memory[memory_index] = 255;
                } else {
                    memory[memory_index] -= 1
                }
            }
            
            '>' => {
                if memory_index == 29999 {
                    memory_index = 0;
                } else {
                    memory_index += 1;
                }
            }

            '<' => {
                if memory_index == 0 {
                    memory_index = 29999;
                } else {
                    memory_index -= 1;
                }
            }

            '.' => print!("{}", memory[memory_index] as char),
            ',' => memory[memory_index] = read_console_input(),

            '[' => {
                if memory[memory_index] == 0 {
                    while program_data.chars().nth(index).unwrap() != ']' || opening_brackets > 0 {
                        index += 1;

                        if program_data.chars().nth(index).unwrap() == '[' {
                            opening_brackets += 1;
                        }
                        
                        if program_data.chars().nth(index).unwrap() == ']' {
                            opening_brackets -= 1;
                        }
                    }
                }
            }

            ']' => {
                if memory[memory_index] != 0 {
                    while program_data.chars().nth(index).unwrap() != '[' || closing_brackets > 0 {
                        index -= 1;

                        if program_data.chars().nth(index).unwrap() == ']' {
                            closing_brackets += 1;
                        }
                        
                        if program_data.chars().nth(index).unwrap() == '[' {
                            closing_brackets -= 1;
                        }
                    }
                }
            }

            _ => { }
        }

        index += 1;
    }
}