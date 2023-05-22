import UIKit

func checkMemoryAvailability(bufferSize: TimeInterval) -> Bool {
    let systemMemory = ProcessInfo.processInfo.physicalMemory
    let pageSize = vm_page_size
    let freeMemory = mach_vm_size_t(mach_task_self_)

    // Calculate the available memory in bytes
    let availableMemory = systemMemory - (UInt64(pageSize) * freeMemory)

    // Calculate the buffer size in bytes
    let bufferSizeBytes = Int(bufferSize) * MemoryLayout<UInt8>.size

    // Check if the available memory is sufficient for the buffer size
    if availableMemory >= bufferSizeBytes * 2 {
        return true
    } else {
        return false
    }
}
