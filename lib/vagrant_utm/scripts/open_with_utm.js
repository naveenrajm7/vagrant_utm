/**
 * Opens a specified UTM file.
 * 
 * This function uses the UTM application to open a UTM file located at the given file path.
 * It mimics the action of opening a Open with UTM.
 * 
 * @param {string} filePath - The file path of the UTM file to be opened.
 * @returns {string} A JSON string indicating the success or failure of the operation.
 */
function run(argv) {
  // Check if a file path is provided
  if (argv.length === 0) {
      console.log("Usage: osascript -l JavaScript open_with_utm.js <path_to_utm_file>");
      return JSON.stringify({ status: "error", message: "No file path provided." });
  }

  const filePath = argv[0];
  const utm = Application('UTM');
  utm.includeStandardAdditions = true;

  try {
      // Attempt to open the UTM file
      utm.open(Path(filePath));
      // Return a success message
      return JSON.stringify({ status: "success", message: "UTM file opened successfully." });
  } catch (error) {
      // Return an error message if the operation fails
      return JSON.stringify({ status: "error", message: error.toString() });
  }
}