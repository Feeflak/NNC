use std::{
    env::{self, args},
    fs::{self, DirBuilder, File, OpenOptions},
    io::{Read, Write},
    path::Path,
    process::Command,
};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct Config {
    project_name: String,
}

fn project_path(config: &Config) -> String {
    let home = env::var("HOME").expect("HOME not set");
    format!("{home}/rec/{}", config.project_name)
}
fn execute_command(cmd: String) {
    println!("CMD: {cmd}");
    Command::new("bash").arg("-c").arg(cmd).output().unwrap();
}
const HELP: &'static str = r#"
rec-start -> start recording
rec-end -> end recording
shot-clipboard -> do a screenshot to clipboard
shot-save -> do a screenshot and open save dialog
proj "PROJECT NAME" -> set project name
manim-logo "Input .svg file path" -> creates an animation for this logo in manim 
manim-note  ->
help -> help
"#;

fn main() {
    let mut args = args();
    args.next();

    let mut config_file = {
        let mut config_path = env::current_exe().unwrap();
        config_path.pop();
        config_path.pop();
        config_path.pop();
        config_path.push("Config.toml");
        println!("config_path: {config_path:?}");
        OpenOptions::new().read(true).open(config_path).unwrap()
    };
    let mut config: Config = {
        let mut contents = String::new();
        config_file.read_to_string(&mut contents).unwrap();
        toml::from_str(&contents).unwrap()
    };
    DirBuilder::new()
        .recursive(true)
        .create(project_path(&config))
        .unwrap();

    println!("config:{config:?}");
    println!("project_path:{:?}", project_path(&config));
    let operation_name = args.next().expect(
        r#"
Operation name was not specified!
add 'help' argument to see all possible operations
"#,
    );
    match operation_name.as_str() {
        "transcode" => {
            while let Some(path_string) = args.next() {
                let path = Path::new(&path_string);
                let parent = path.parent().unwrap();
                let stem = path.file_stem().unwrap().to_string_lossy();

                let mut new_name = String::with_capacity(stem.len() + 7);
                new_name.push_str(&stem);
                new_name.push_str(".mov");

                let transcoded_file_path = parent.join(new_name);
                execute_command(format!(
                    "ffmpeg -i {path_string} \
        -vf fps=60 \
        -c:v dnxhd -profile:v dnxhr_sq \
        -pix_fmt yuv422p \
        -c:a pcm_s16le \
                    {}",
                    transcoded_file_path.to_str().unwrap()
                ));
            }
        }
        "rec-end" => {
            execute_command("pkill -INT -f gpu-screen-recorder".to_string());
            execute_command("pkill -INT -x pw-record".to_string());
        }
        "rec-app-audio" => {
            DirBuilder::new()
                .recursive(true)
                .create(project_path(&config) + "/rec/")
                .unwrap();
            execute_command(format!(
                r#"
gpu-screen-recorder -v yes \
          -w screen \
          -f 60 \
          -a default_output \
          -k av1_hdr \
          -o "{}/recording_$(date +%F_%H-%M-%S).mkv" 
"#,
                project_path(&config) + "/rec"
            ))
        }
        "rec-start" => {
            DirBuilder::new()
                .recursive(true)
                .create(project_path(&config) + "/rec/")
                .unwrap();
            execute_command(format!(
                r#"
gpu-screen-recorder -v yes \
          -w screen \
          -f 60 \
          -a default_input \
          -k av1_hdr \
          -o "{}/recording_$(date +%F_%H-%M-%S).mkv" 
"#,
                project_path(&config) + "/rec"
            ))
        }
        "shot-save" => execute_command(format!(
            r#"
file=$(zenity --file-selection \
              --save \
              --confirm-overwrite \
              --filename="{}/Screenshot-$(date +%F-%H%M%S).png")

[ -n "$file" ] && grimblast save area "$file"
"#,
            project_path(&config)
        )),
        "shot-clipboard" => execute_command(format!("grimblast -n copy area",)),
        "proj" => {
            let mut config_file = {
                let mut config_path = env::current_exe().unwrap();
                config_path.pop();
                config_path.pop();
                config_path.pop();
                config_path.push("Config.toml");
                println!("config_path: {config_path:?}");
                OpenOptions::new()
                    .read(true)
                    .write(true)
                    .truncate(true)
                    .open(config_path)
                    .unwrap()
            };
            config.project_name = args.next().expect("expected a project name!");
            let text = toml::to_string(&config);
            config_file.write(text.unwrap().as_bytes()).unwrap();
        }
        "vo" => {
            DirBuilder::new()
                .recursive(true)
                .create(project_path(&config) + "/vo/")
                .unwrap();
            execute_command(format!(
                r#"
pw-record "{}/recording_$(date +%F_%H-%M-%S).wav"
"#,
                project_path(&config) + "/vo"
            ))
        }

        "manim-note" => {
            {
                let title = args.next().expect("expected a title name!");
                let mut title_file = OpenOptions::new()
                    .read(true)
                    .write(true)
                    .truncate(true)
                    .open("/etc/nixos/NNC/utils/manim/notes/title.txt")
                    .unwrap();
                title_file.write(&title.into_bytes()).unwrap();
            }
            {
                let contents = args.next().expect("expected contents !");
                let mut contents_file = OpenOptions::new()
                    .read(true)
                    .write(true)
                    .truncate(true)
                    .open("/etc/nixos/NNC/utils/manim/notes/text.txt")
                    .unwrap();
                contents_file.write(&contents.into_bytes()).unwrap();
            }

            execute_command(format!(
                r#"manim  -r 3840,2160  --fps 60 --transparent   -qh /etc/nixos/NNC/utils/manim/notes/main.py --media_dir /etc/nixos/NNC/utils/manim/notes/media; /etc/nixos/NNC/utils/manim/notes/combine.bash"#,
            ));
        }

        "manim-write" => {
            {
                let title = args.next().expect("expected a title name!");
                let mut file = OpenOptions::new()
                    .read(true)
                    .write(true)
                    .truncate(true)
                    .open("/etc/nixos/NNC/utils/manim/write/text.txt")
                    .unwrap();
                file.write(&title.into_bytes()).unwrap();
            }

            {
                if let Some(font_size) = args.next() {
                    let mut file = OpenOptions::new()
                        .read(true)
                        .write(true)
                        .truncate(true)
                        .open("/etc/nixos/NNC/utils/manim/write/font_size.txt")
                        .unwrap();
                    file.write(&font_size.into_bytes()).unwrap();
                }
            }

            execute_command(format!(
                r#"manim -r 3840,2160  --fps 60 --transparent  --media_dir /etc/nixos/NNC/utils/manim/write/media --format mov -qh /etc/nixos/NNC/utils/manim/write/manin.py ; cp  "/etc/nixos/NNC/utils/manim/write/media/videos/manin/2160p60/ShowWriteReversed.mov" "./write_anim.mov""#,
            ));
        }
        "manim-logo" => {
            let logo_path = args.next().expect("expected a logo file path!");
            execute_command(format!(
                r#"cp {} "/etc/nixos/NNC/utils/manim/logo/logo.svg" ;manim -r 3840,2160  --fps 60 --transparent  --media_dir /etc/nixos/NNC/utils/manim/logo/media --format mov -qh /etc/nixos/NNC/utils/manim/logo/main.py ; cp  "/etc/nixos/NNC/utils/manim/logo/media/videos/main/2160p60/DefaultTemplate.mov" "./logo_anim.mov""#,
                logo_path
            ));
        }
        "help" => {
            println!("{}", HELP)
        }

        _ => {
            println!("Unknown operation name!");
            println!("{}", HELP)
        }
    };
}
