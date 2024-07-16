/**
 * Lists all virtual machines managed by UTM and returns their details in JSON format.
 * 
 * Mimics the `utmctl list` command.
 * UUID, Name, and Status
 * 
 * @returns {string} A JSON string representing an array of objects, each object containing
 *                   the UUID, Name, and Status of a virtual machine.
 */
function utmctlListVMs() {
  const utm = Application('UTM');
  utm.includeStandardAdditions = true;

  // Listing virtual machines
  const vms = utm.virtualMachines();
  const vmList = [];

  // Loop through all virtual machines
  for (const vm of vms) {
      const vmID = vm.id();
      const vmName = vm.name();
      const vmStatus = vm.status();
      const vmDict = { UUID: vmID, Name: vmName, Status: vmStatus };
      vmList.push(vmDict);
  }

  // Convert list to JSON
  const jsonString = JSON.stringify(vmList);
  return jsonString;
}

utmctlListVMs();