{-# LANGUAGE UnicodeSyntax #-}

module Cpmk (initProj) where

import System.Directory (
  createDirectoryIfMissing,
  getCurrentDirectory,
 )
import System.FilePath (takeDirectory)

data Cpmk = Cpmk
  { projectName :: String
  , language :: String
  }

createDirs projectPath = do
  putStrLn "Creating directories..."
  let srcPath = projectPath ++ "/src"
  createDirectoryIfMissing True srcPath
  putStrLn "Directories created successfully."

createFiles projectPath cpmk = do
  putStrLn "Creating files..."
  let mainPath = projectPath ++ "/src/main." ++ language cpmk
  let _ = takeDirectory mainPath
  let mainContent =
        if language cpmk == "c"
          then
            "#include <stdio.h>\n\n"
              ++ "int main() {\n"
              ++ "  printf(\"Hello, World!\\n\");\n\n"
              ++ "  return 0;\n"
              ++ "}"
          else
            "#include <iostream>\n\n"
              ++ "int main() {\n"
              ++ "  std::cout << \"Hello, World!\\n\";\n\n"
              ++ "  return 0;\n"
              ++ "}"
  writeFile mainPath mainContent
  let cmakePath = projectPath ++ "/CMakeLists.txt"
  let cmakeContent =
        if language cpmk == "c"
          then
            "cmake_minimum_required(VERSION 3.10)\n\n"
              ++ "project("
              ++ projectName cpmk
              ++ ")\n\n"
              ++ "set(CMAKE_C_STANDARD 17)\n\n"
              ++ "set(CMAKE_C_STANDARD_REQUIRED True)\n\n"
              ++ "set(CMAKE_C_FLAGS \"-Wall -Wextra -Werror\")\n\n"
              ++ "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})\n\n"
              ++ "add_subdirectory(src)"
          else
            "cmake_minimum_required(VERSION 3.10)\n\n"
              ++ "project("
              ++ projectName cpmk
              ++ ")\n\n"
              ++ "set(CMAKE_CXX_STANDARD 17)\n\n"
              ++ "set(CMAKE_CXX_STANDARD_REQUIRED True)\n\n"
              ++ "set(CMAKE_CXX_FLAGS \"-Wall -Wextra -Werror\")\n\n"
              ++ "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})\n\n"
              ++ "add_subdirectory(src)"
  let _ = takeDirectory cmakePath
  writeFile cmakePath cmakeContent
  let cmakeSrcPath = projectPath ++ "/src/CMakeLists.txt"
  let cmakeSrcContent =
        "add_executable(\n"
          ++ "  "
          ++ projectName cpmk
          ++ "\n"
          ++ "  main."
          ++ language cpmk
          ++ "\n"
          ++ ")"
  let _ = takeDirectory cmakeSrcPath
  writeFile cmakeSrcPath cmakeSrcContent
  putStrLn "Files created successfully."

setupProject :: Cpmk -> IO ()
setupProject cpmk = do
  putStrLn "Setting up project..."
  putStrLn $ "Project name: " ++ projectName cpmk
  putStrLn $ "Language: " ++ language cpmk
  dir <- getCurrentDirectory
  let projectPath = dir ++ "/" ++ projectName cpmk
  createDirs projectPath
  createFiles projectPath cpmk

isValid language = language == "c" || language == "cpp"

initProj :: IO ()
initProj = do
  let cpmk =
        Cpmk
          { projectName = "teste"
          , language = "c"
          }
  if not . isValid . language $ cpmk
    then putStrLn "Invalid language. Supported languages: c, cpp."
    else do
      setupProject cpmk
      putStrLn $ "Project " ++ projectName cpmk ++ " created successfully."
