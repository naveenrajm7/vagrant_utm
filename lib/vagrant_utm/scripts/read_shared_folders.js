/**
 * Reads the shared directory IDs from the QEMU additional arguments of a specified VM in UTM.
 * 
 * This function uses the UTM application to read the QEMU additional arguments
 * of a VM identified by the given VM ID and extracts the IDs of shared directories.
 * 
 * @param {string} vmIdentifier - The ID of the VM.
 * @returns {string} A JSON string containing the shared directory IDs or an error message.
 */
function run(argv) {
  // Check if a VM ID is provided
  if (argv.length === 0) {
      console.log("Usage: osascript -l JavaScript read_shared_directories.js <vm_id>");
      return JSON.stringify({ status: false, result: "No VM ID provided." });
  }

  const vmIdentifier = argv[0];
  const utm = Application('UTM');
  utm.includeStandardAdditions = true;

  try {
      // Attempt to get the VM by ID
      const vm = utm.virtualMachines.byId(vmIdentifier);
      // Get the config of the VM
      const config = vm.configuration();
      // Get the QEMU additional arguments
      const qemuArgs = config.qemuAdditionalArguments;
      
      // Extract shared directory IDs
      const sharedDirIds = [];
      qemuArgs.forEach(arg => {
          const argStr = arg.argumentString;
          if (argStr.startsWith("-fsdev")) {
              const match = argStr.match(/id=([^,]+)/);
              if (match) {
                  sharedDirIds.push(match[1]);
              }
          }
      });

      // Return the shared directory IDs
      return JSON.stringify({ status: true, result: sharedDirIds });
  } catch (error) {
      // Return an error message
      return JSON.stringify({ status: false, result: error.message });
  }
}