; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf-pc-linux"

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64 %0, i64 %1) #0

define i64 @"interval:s:1"(i8* %0) section "s_interval:s:1_1" {
entry:
  %"@_val" = alloca i64, align 8
  %"@_key" = alloca i64, align 8
  %lookup_elem_val = alloca i64, align 8
  %elapsed_key = alloca i64, align 8
  %1 = bitcast i64* %elapsed_key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %elapsed_key, align 8
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %lookup_elem = call i8* inttoptr (i64 1 to i8* (i64, i64*)*)(i64 %pseudo, i64* %elapsed_key)
  %2 = bitcast i64* %lookup_elem_val to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %2)
  %map_lookup_cond = icmp ne i8* %lookup_elem, null
  br i1 %map_lookup_cond, label %lookup_success, label %lookup_failure

lookup_success:                                   ; preds = %entry
  %cast = bitcast i8* %lookup_elem to i64*
  %3 = load i64, i64* %cast, align 8
  store i64 %3, i64* %lookup_elem_val, align 8
  br label %lookup_merge

lookup_failure:                                   ; preds = %entry
  store i64 0, i64* %lookup_elem_val, align 8
  br label %lookup_merge

lookup_merge:                                     ; preds = %lookup_failure, %lookup_success
  %4 = load i64, i64* %lookup_elem_val, align 8
  %5 = bitcast i64* %lookup_elem_val to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %5)
  %get_ns = call i64 inttoptr (i64 125 to i64 ()*)()
  %6 = sub i64 %get_ns, %4
  %7 = bitcast i64* %elapsed_key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %7)
  %8 = bitcast i64* %"@_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %8)
  store i64 0, i64* %"@_key", align 8
  %9 = bitcast i64* %"@_val" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %9)
  store i64 %6, i64* %"@_val", align 8
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 0)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, i64*, i64)*)(i64 %pseudo1, i64* %"@_key", i64* %"@_val", i64 0)
  %10 = bitcast i64* %"@_val" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %10)
  %11 = bitcast i64* %"@_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %11)
  ret i64 0
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg %0, i8* nocapture %1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
