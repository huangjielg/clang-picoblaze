// RUN: %clang_cc1 -x objective-c++ -triple x86_64-apple-darwin10 -emit-llvm -fcxx-exceptions -fexceptions -fobjc-exceptions -o - %s | FileCheck %s

@interface OCType @end
void opaque();

namespace test0 {

  // CHECK: define void @_ZN5test03fooEv
  void foo() {
    try {
      // CHECK: invoke void @_Z6opaquev
      opaque();
    } catch (OCType *T) {
      // CHECK:      landingpad { i8*, i32 } personality i8* bitcast (i32 (...)* @__objc_personality_v0 to i8*)
      // CHECK-NEXT:   catch %struct._objc_typeinfo* @"OBJC_EHTYPE_$_OCType"
    }
  }
}

// rdar://12605907
@interface NSException
  + new;
@end
namespace test1 {

  void bar() {
    @try {
      throw [NSException new];
    } @catch (id i) {
    }
  }
// CHECK: invoke void @objc_exception_throw(i8* [[CALL:%.*]]) noreturn
// CHECK:          to label [[INVOKECONT1:%.*]] unwind label [[LPAD:%.*]]
}
