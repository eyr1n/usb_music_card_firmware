const std = @import("std");

const c_sources = [_][]const u8{
    "Core/Src/main.c",
    "Core/Src/stm32f4xx_it.c",
    "Core/Src/stm32f4xx_hal_msp.c",
    "FATFS/Target/usbh_diskio.c",
    "FATFS/App/fatfs.c",
    "USB_HOST/App/usb_host.c",
    "USB_HOST/Target/usbh_conf.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_hcd.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_usb.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c_ex.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2s.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2s_ex.c",
    "Core/Src/system_stm32f4xx.c",
    "Middlewares/Third_Party/FatFs/src/diskio.c",
    "Middlewares/Third_Party/FatFs/src/ff.c",
    "Middlewares/Third_Party/FatFs/src/ff_gen_drv.c",
    "Middlewares/Third_Party/FatFs/src/option/syscall.c",
    "Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_core.c",
    "Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ctlreq.c",
    "Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_ioreq.c",
    "Middlewares/ST/STM32_USB_Host_Library/Core/Src/usbh_pipes.c",
    "Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc.c",
    "Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_bot.c",
    "Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Src/usbh_msc_scsi.c",
    "Core/Src/sysmem.c",
    "Core/Src/syscalls.c",
    "Core/Src/dr_wav.c",
};

const asm_sources = [_][]const u8{
    "startup_stm32f446xx.s",
};

const c_includes = [_][]const u8{
    "FATFS/Target",
    "FATFS/App",
    "USB_HOST/App",
    "USB_HOST/Target",
    "Core/Inc",
    "Drivers/STM32F4xx_HAL_Driver/Inc",
    "Drivers/STM32F4xx_HAL_Driver/Inc/Legacy",
    "Middlewares/Third_Party/FatFs/src",
    "Middlewares/ST/STM32_USB_Host_Library/Core/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc",
    "Drivers/CMSIS/Device/ST/STM32F4xx/Include",
    "Drivers/CMSIS/Include",
};

const c_macros = [_]struct { []const u8, []const u8 }{
    .{ "USE_HAL_DRIVER", "1" },
    .{ "STM32F446xx", "1" },
    .{ "DR_WAV_NO_STDIO", "1" },
    .{ "sbrk", "_sbrk_unused" }, // for picolibc
    .{ "exit", "_exit_unused" }, // for picolibc
};

const linker_script = "STM32F446XX_FLASH.ld";

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .cpu_features_add = std.Target.arm.featureSet(&.{.vfp4d16sp}),
        .os_tag = .freestanding,
        .abi = .eabihf,
    });

    const optimize = b.standardOptimizeOption(.{});

    const exe = addElfStep(b, AddElfModOptions{
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
}

const AddElfModOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

fn addElfStep(b: *std.Build, options: AddElfModOptions) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "usb_music_card_firmware.elf",
        .root_module = addElfMod(b, options),
    });

    exe.entry = .disabled;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    exe.link_gc_sections = true;

    exe.setLibCFile(b.path("libc.txt"));
    exe.setLinkerScript(b.path("stm32cubemx").path(b, linker_script));

    return exe;
}

fn addElfMod(b: *std.Build, options: AddElfModOptions) *std.Build.Module {
    const mod = b.createModule(.{
        .root_source_file = b.path("src/entry_c.zig"),
        .target = options.target,
        .optimize = options.optimize,
        .link_libc = true,
        .sanitize_c = .off,
    });

    mod.addCSourceFiles(.{
        .root = b.path("stm32cubemx"),
        .files = &c_sources,
    });
    for (asm_sources) |source| {
        mod.addAssemblyFile(b.path("stm32cubemx").path(b, source));
    }
    for (c_includes) |include| {
        mod.addIncludePath(b.path("stm32cubemx").path(b, include));
    }
    for (c_macros) |macro| {
        mod.addCMacro(macro[0], macro[1]);
    }

    // picolibc
    mod.addObjectFile(b.path("picolibc-install/lib/libc.a"));

    mod.addImport("stm32cubemx", addStm32cubemxMod(b, options));

    return mod;
}

fn addStm32cubemxMod(b: *std.Build, options: AddElfModOptions) *std.Build.Module {
    const stm32cubemx = b.addTranslateC(.{
        .root_source_file = b.path("src/stm32cubemx.h"),
        .target = options.target,
        .optimize = options.optimize,
    });

    for (c_includes) |include| {
        stm32cubemx.addIncludePath(b.path("stm32cubemx").path(b, include));
    }
    for (c_macros) |macro| {
        stm32cubemx.defineCMacro(macro[0], macro[1]);
    }

    // picolibc
    stm32cubemx.addSystemIncludePath(b.path("picolibc-install/include"));

    return stm32cubemx.createModule();
}
