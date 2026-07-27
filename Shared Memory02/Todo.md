program VirtQueryExample;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils;

procedure DumpProcessMemory(ProcessID: DWORD);
var
  hProcess: THandle;
  pAddress: Pointer;
  mbi: TMemoryBasicInformation;
begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION, False, ProcessID);
  if hProcess = 0 then
  begin
    Writeln('Could not open process.');
    Exit;
  end;

  pAddress := nil;
  Writeln('Base Address    Region Size     State      Protection');
  Writeln('-----------------------------------------------------');

  // Loop through the virtual address space
  while VirtualQueryEx(hProcess, pAddress, @mbi, SizeOf(mbi)) <> 0 do
  begin
    Writeln(
      IntToHex(NativeUInt(mbi.BaseAddress), 8), '   ',
      IntToHex(NativeUInt(mbi.RegionSize), 8),  '   ',
      IntToHex(mbi.State, 8),                  '   ',
      IntToHex(mbi.Protect, 8)
    );

    // Advance the pointer to the next memory region
    pAddress := Pointer(NativeUInt(pAddress) + mbi.RegionSize);
  end;

  CloseHandle(hProcess);
end;

begin
  // Replace 1234 with a valid Target Process ID (PID)
  DumpProcessMemory(1234);
  Readln;
end.
```

### Key Details
* **`hProcess`**: A handle opened with `PROCESS_QUERY_INFORMATION` rights.
* **`pAddress`**: The starting address for the query, which gets incremented by `RegionSize` on each loop iteration to scan the whole memory space.
* **`mbi`**: A [MEMORY_BASIC_INFORMATION](https://microsoft.com) record that holds details like allocation state and protection flags.

<FollowUp>
If you want, let me know:
* What you plan to do with the **memory blocks** (e.g., read contents, scan for patterns)
* Whether you need help targeting a process by **name** instead of PID

I can update the code sample to fit your exact goal.
</FollowUp>