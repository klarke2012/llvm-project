//===-- llvm-objdump.h ----------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_OBJDUMP_H
#define LLVM_OBJDUMP_H

#include "llvm/ADT/StringRef.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/MemoryObject.h"

namespace llvm {

namespace object {
  class COFFObjectFile;
  class ObjectFile;
  class RelocationRef;
}
class error_code;

extern cl::opt<std::string> TripleName;
extern cl::opt<std::string> ArchName;

// Various helper functions.
bool error(error_code ec);
bool RelocAddressLess(object::RelocationRef a, object::RelocationRef b);
void DumpBytes(StringRef bytes);
void DisassembleInputMachO(StringRef Filename);
void printCOFFUnwindInfo(const object::COFFObjectFile* o);
void printELFFileHeader(const object::ObjectFile *o);

class StringRefMemoryObject : public MemoryObject {
  virtual void anchor();
  StringRef Bytes;
  uint64_t Base;
public:
  StringRefMemoryObject(StringRef bytes, uint64_t Base = 0)
    : Bytes(bytes), Base(Base) {}

  uint64_t getBase() const { return Base; }
  uint64_t getExtent() const { return Bytes.size(); }

  int readByte(uint64_t Addr, uint8_t *Byte) const {
    if (Addr >= Base + getExtent() || Addr < Base)
      return -1;
    *Byte = Bytes[Addr - Base];
    return 0;
  }
};

}

#endif
