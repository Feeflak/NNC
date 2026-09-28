use std::{
    env::{self, args},
    fs::{self, DirBuilder, OpenOptions},
    io::{Read, Write},
    path::Path,
    process::Command,
};

use image::ImageFormat;
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
fn execute_command_checked(cmd: String) -> bool {
    println!("CMD: {cmd}");
    match Command::new("bash").arg("-c").arg(cmd).output() {
        Ok(output) => output.status.success(),
        Err(_) => false,
    }
}
fn get_codec_name(path: &str, stream_type: char) -> Option<String> {
    let stream_selector = format!("{}:0", stream_type);
    let output = Command::new("ffprobe")
        .args(&[
            "-v",
            "error",
            "-select_streams",
            &stream_selector,
            "-show_entries",
            "stream=codec_name",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            path,
        ])
        .output()
        .ok()?;
    let codec = String::from_utf8_lossy(&output.stdout).trim().to_string();
    if codec.is_empty() {
        None
    } else {
        Some(codec)
    }
}
fn get_all_audio_codecs(path: &str) -> Vec<String> {
    let output = Command::new("ffprobe")
        .args(&[
            "-v",
            "error",
            "-select_streams",
            "a",
            "-show_entries",
            "stream=codec_name",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            path,
        ])
        .output()
        .ok();
    match output {
        Some(output) => String::from_utf8_lossy(&output.stdout)
            .lines()
            .map(|s| s.trim().to_string())
            .filter(|s| !s.is_empty())
            .collect(),
        None => Vec::new(),
    }
}
fn transcode_single_file(
    path_string: &str,
    remove_original: bool,
    video_codec: Option<&str>,
    audio_codecs: &[String],
) {
    let path = Path::new(path_string);
    let parent = path.parent().unwrap();
    let stem = path.file_stem().unwrap().to_string_lossy();

    let mut new_name = String::with_capacity(stem.len() + 7);
    new_name.push_str(&stem);
    new_name.push('T');
    new_name.push_str(".mkv");

    let video_options = if video_codec == Some("av1") {
        "-c:v copy".to_string()
    } else {
        "-c:v av1_nvenc -preset p5 -cq 28 -pix_fmt yuv420p -colorspace bt709 -color_primaries bt709 -color_trc bt709 -color_range pc".to_string()
    };

    let all_audio_flac = !audio_codecs.is_empty() && audio_codecs.iter().all(|c| c == "flac");
    let audio_options = if all_audio_flac {
        "-c:a copy".to_string()
    } else {
        "-c:a flac".to_string()
    };

    let transcoded_file_path = parent.join(new_name);
    let output_path = transcoded_file_path.to_str().unwrap();
    let success = execute_command_checked(format!(
        "ffmpeg -i {path_string} {video_options} {audio_options} {output_path}"
    ));

    if remove_original && success {
        println!("REMOVE: {path_string}");
        fs::remove_file(path_string).unwrap();
    }
}
fn is_video_file(path: &Path) -> bool {
    const VIDEO_EXTENSIONS: &[&str] = &[
        "mkv", "mp4", "avi", "mov", "webm", "ts", "m2ts", "flv", "wmv", "mpg", "mpeg", "m4v",
    ];
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| VIDEO_EXTENSIONS.contains(&e.to_lowercase().as_str()))
        .unwrap_or(false)
}
fn is_existing_transcode(path: &Path) -> bool {
    path.file_stem()
        .unwrap_or_default()
        .to_string_lossy()
        .ends_with('T')
}
fn collect_video_files(dir: &Path, files: &mut Vec<std::path::PathBuf>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() && is_video_file(&path) && !is_existing_transcode(&path) {
                files.push(path);
            } else if path.is_dir() {
                collect_video_files(&path, files);
            }
        }
    }
}
fn convert_jpg_single_file(path_string: &str, remove_original: bool) {
    let path = Path::new(path_string);
    let parent = path.parent().unwrap();
    let stem = path.file_stem().unwrap().to_string_lossy();

    let mut new_name = String::with_capacity(stem.len() + 5);
    new_name.push_str(&stem);
    new_name.push('J');
    new_name.push_str(".jpg");

    let output_path = parent.join(new_name);
    let output_path_string = output_path.to_str().unwrap();

    let success = if is_heic_file(path) {
        if execute_command_checked(format!(
            "ffmpeg -i {path_string} -q:v 2 {output_path_string}"
        )) {
            Ok(())
        } else {
            Err(image::ImageError::Encoding(
                image::error::EncodingError::new(
                    image::error::ImageFormatHint::Name("heic".to_string()),
                    "ffmpeg heic conversion failed",
                ),
            ))
        }
    } else {
        match image::open(path_string) {
            Ok(img) => img.save_with_format(output_path_string, ImageFormat::Jpeg),
            Err(err) => Err(err),
        }
    };

    println!("{success:?}");

    if remove_original && success.is_ok() {
        println!("REMOVE: {path_string}");
        fs::remove_file(path_string).unwrap();
    }
}
fn is_photo_file(path: &Path) -> bool {
    const PHOTO_EXTENSIONS: &[&str] = &[
        "jpg", "jpeg", "png", "bmp", "tiff", "tif", "webp", "gif", "heic", "heif", "avif",
        "ppm", "pgm", "pbm",
    ];
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| PHOTO_EXTENSIONS.contains(&e.to_lowercase().as_str()))
        .unwrap_or(false)
}
fn is_jpg_file(path: &Path) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| {
            let e = e.to_lowercase();
            e == "jpg" || e == "jpeg"
        })
        .unwrap_or(false)
}
fn is_heic_file(path: &Path) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| {
            let e = e.to_lowercase();
            e == "heic" || e == "heif"
        })
        .unwrap_or(false)
}
fn is_existing_jpg_conversion(path: &Path) -> bool {
    path.file_stem()
        .unwrap_or_default()
        .to_string_lossy()
        .ends_with('J')
}
fn collect_photo_files(dir: &Path, files: &mut Vec<std::path::PathBuf>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() && is_photo_file(&path) && !is_existing_jpg_conversion(&path) {
                files.push(path);
            } else if path.is_dir() {
                collect_photo_files(&path, files);
            }
        }
    }
}
fn convert_single_file(path_string: &str, remove_original: bool) {
    let path = Path::new(path_string);
    if is_video_file(path) && !is_existing_transcode(path) {
        let video_codec = get_codec_name(path_string, 'v');
        let audio_codecs = get_all_audio_codecs(path_string);
        transcode_single_file(
            path_string,
            remove_original,
            video_codec.as_deref(),
            &audio_codecs,
        );
    } else if is_photo_file(path) && !is_existing_jpg_conversion(path) && !is_jpg_file(path) {
        convert_jpg_single_file(path_string, remove_original);
    }
}
fn collect_media_files(dir: &Path, files: &mut Vec<std::path::PathBuf>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file()
                && ((is_video_file(&path) && !is_existing_transcode(&path))
                    || (is_photo_file(&path)
                        && !is_existing_jpg_conversion(&path)
                        && !is_jpg_file(&path)))
            {
                files.push(path);
            } else if path.is_dir() {
                collect_media_files(&path, files);
            }
        }
    }
}
const HELP: &'static str = r#"
rec-start -> start recording
rec-app-audio -> start recording application audio
rec-end -> end recording
shot-clipboard -> screenshot to clipboard
shot-save -> screenshot with save dialog
vo -> record voice-over
proj "PROJECT NAME" -> set project name
transcode [paths...] [-r] -> transcode videos to av1+flac mkv
transcode-recursive [paths...] [-r] -> recursively transcode videos to av1+flac mkv
convert-jpg [paths...] [-r] -> convert photos to jpg
convert-jpg-recursive [paths...] [-r] -> recursively convert photos to jpg
convert [paths...] [-r] -> convert images and videos in given paths
convert-recursive [paths...] [-r] -> recursively convert images and videos
manim-logo "Input .svg file path" -> create logo animation
manim-note "title" "contents" -> create note animation
manim-write "text" [font_size] -> create write animation
help -> show this help
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
            let mut remove_original = false;
            let paths: Vec<String> = args
                .filter(|arg| {
                    if arg == "-r" {
                        remove_original = true;
                        false
                    } else {
                        true
                    }
                })
                .collect();

            for path_string in paths {
                let video_codec = get_codec_name(&path_string, 'v');
                let audio_codecs = get_all_audio_codecs(&path_string);
                transcode_single_file(
                    &path_string,
                    remove_original,
                    video_codec.as_deref(),
                    &audio_codecs,
                );
            }
        }
        "transcode-recursive" => {
            let mut remove_original = false;
            let paths: Vec<String> = args
                .filter(|arg| {
                    if arg == "-r" {
                        remove_original = true;
                        false
                    } else {
                        true
                    }
                })
                .collect();

            let mut video_files = Vec::new();
            for path_string in paths {
                let path = Path::new(&path_string);
                if path.is_dir() {
                    collect_video_files(path, &mut video_files);
                } else if path.is_file() && is_video_file(path) && !is_existing_transcode(path) {
                    video_files.push(path.to_path_buf());
                }
            }

            for video_path in video_files {
                let path_string = video_path.to_string_lossy().to_string();
                let video_codec = get_codec_name(&path_string, 'v');
                let audio_codecs = get_all_audio_codecs(&path_string);
                let all_audio_flac =
                    !audio_codecs.is_empty() && audio_codecs.iter().all(|c| c == "flac");

                if video_codec.as_deref() == Some("av1") && all_audio_flac {
                    println!("SKIP: {path_string} (already av1 + flac)");
                    continue;
                }

                transcode_single_file(
                    &path_string,
                    remove_original,
                    video_codec.as_deref(),
                    &audio_codecs,
                );
            }
        }
        "convert-jpg" => {
            let mut remove_original = false;
            let paths: Vec<String> = args
                .filter(|arg| {
                    if arg == "-r" {
                        remove_original = true;
                        false
                    } else {
                        true
                    }
                })
                .collect();

            for path_string in paths {
                convert_jpg_single_file(&path_string, remove_original);
            }
        }
        "convert-jpg-recursive" => {
            let mut remove_original = false;
            let paths: Vec<String> = args
                .filter(|arg| {
                    if arg == "-r" {
                        remove_original = true;
                        false
                    } else {
                        true
                    }
                })
                .collect();

            let mut photo_files = Vec::new();
            for path_string in paths {
                let path = Path::new(&path_string);
                if path.is_dir() {
                    collect_photo_files(path, &mut photo_files);
                } else if path.is_file() && is_photo_file(path) && !is_existing_jpg_conversion(path)
                {
                    photo_files.push(path.to_path_buf());
                }
            }

            for photo_path in photo_files {
                let path_string = photo_path.to_string_lossy().to_string();
                if is_jpg_file(&photo_path) {
                    println!("SKIP: {path_string} (already jpg)");
                    continue;
                }
                convert_jpg_single_file(&path_string, remove_original);
            }
        }
        "convert" => {
            let mut remove_original = false;
            let paths: Vec<String> = args
                .filter(|arg| {
                    if arg == "-r" {
                        remove_original = true;
                        false
                    } else {
                        true
                    }
                })
                .collect();

            for path_string in paths {
                convert_single_file(&path_string, remove_original);
            }
        }
        "convert-recursive" => {
            let mut remove_original = false;
            let paths: Vec<String> = args
                .filter(|arg| {
                    if arg == "-r" {
                        remove_original = true;
                        false
                    } else {
                        true
                    }
                })
                .collect();

            let mut media_files = Vec::new();
            for path_string in paths {
                let path = Path::new(&path_string);
                if path.is_dir() {
                    collect_media_files(path, &mut media_files);
                } else if path.is_file() {
                    if (is_video_file(path) && !is_existing_transcode(path))
                        || (is_photo_file(path)
                            && !is_existing_jpg_conversion(path)
                            && !is_jpg_file(path))
                    {
                        media_files.push(path.to_path_buf());
                    }
                }
            }

            for media_path in media_files {
                let path_string = media_path.to_string_lossy().to_string();
                convert_single_file(&path_string, remove_original);
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
        -w portal \
        -f 60 \
        -a default_output \
        -ac flac \
        -k av1 \
        -cr full \
        -q high \
        -restore-portal-session yes \
        -portal-session-token-filepath ~/.config/gsr-portal-token.txt \
        -o "{}/recording_$(date +%F_%H-%M-%S).mkv"
"#,
                project_path(&config) + "/rec"
            ))
        }

        "rec-all" => {
            DirBuilder::new()
                .recursive(true)
                .create(project_path(&config) + "/rec/")
                .unwrap();
            execute_command(format!(
                r#"
gpu-screen-recorder -v yes \
        -w portal \
        -f 60 \
        -a default_input \
        -a default_output \
        -ac flac \
        -k av1 \
        -cr full \
        -q high \
        -restore-portal-session yes \
        -portal-session-token-filepath ~/.config/gsr-portal-token.txt \
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
        -w portal \
        -f 60 \
        -a default_input \
        -ac flac \
        -k av1 \
        -cr full \
        -q high \
        -restore-portal-session yes \
        -portal-session-token-filepath ~/.config/gsr-portal-token.txt \
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
