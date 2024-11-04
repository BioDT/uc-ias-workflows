import os
import shutil

def delete_files(directory):
    """
    Deletes all files and directories within the specified directory.
    Args:
        directory (str): The path to the directory from which all files and directories will be deleted.
    Returns:
        None
    Prints:
        - A message if the directory does not exist.
        - A message if the path is not a directory.
        - A message for each file or directory that is deleted.
        - A message when all files in the directory have been deleted.
        - An error message if an exception occurs during the deletion process.
    """
    
    if not os.path.exists(directory):
        print(f"Directory {directory} does not exist.")
        return

    if not os.path.isdir(directory):
        print(f"{directory} is not a directory.")
        return

    try:
        for filename in os.listdir(directory):
            file_path = os.path.join(directory, filename)
            if os.path.isfile(file_path):
                os.remove(file_path)
                print(f"Deleted file: {file_path}")
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
                print(f"Deleted directory and its contents: {file_path}")
        print(f"All files in {directory} have been deleted.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
# delete_all_files('/path/to/directory')