/**
 * Reads the shared folder QEMU arguments for specified IDs from the QEMU additional arguments of a VM in UTM.
 * 
 * This function uses the UTM application to read the QEMU additional arguments
 * of a VM identified by the given VM ID and extracts the arguments for the specified IDs.
 * 
 * @param {string} vmIdentifier - The ID of the VM.
 * @param {string} ids - Comma-separated list of directory IDs.
 * @returns {string} A JSON string containing the QEMU arguments for the specified IDs or an error message.
 */
function run(argv) {
  // Check if a VM ID and IDs are provided
  if (argv.length < 2) {
      console.log("Usage: osascript -l JavaScript read_shared_folders_args.js <vm_id> --ids <dirID>,<dirID>");
      return JSON.stringify({ status: false, result: "No VM ID or IDs provided." });
  }

  const vmIdentifier = argv[0];
  const idsArgIndex = argv.indexOf("--ids");
  if (idsArgIndex === -1 || idsArgIndex + 1 >= argv.length) {
      return JSON.stringify({ status: false, result: "No IDs provided." });
  }
  const ids = argv[idsArgIndex + 1].split(",");

  const utm = Application('UTM');
  utm.includeStandardAdditions = true;

  try {
      // Attempt to get the VM by ID
      const vm = utm.virtualMachines.byId(vmIdentifier);
      // Get the config of the VM
      const config = vm.configuration();
      // Get the QEMU additional arguments
      const qemuArgs = config.qemuAdditionalArguments;

      // Extract QEMU arguments for the specified IDs
      const sharedDirArgs = [];
      qemuArgs.forEach(arg => {
          const argStr = arg.argumentString;
          ids.forEach(id => {
              if (argStr.includes(`id=${id}`) || argStr.includes(`fsdev=${id}`)) {
                  sharedDirArgs.push(argStr);
              }
          });
      });

      // Return the QEMU arguments for the specified IDs
      return JSON.stringify({ status: true, result: sharedDirArgs });
  } catch (error) {
      // Return an error message
      return JSON.stringify({ status: false, result: error.message });
  }
}