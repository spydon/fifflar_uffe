// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      AC: Function.prototype.call.bind(DataView.prototype.setInt16),
      AD: x0 => x0.screen,
      AE: x0 => new ResizeObserver(x0),
      AF: x0 => x0.wheelDeltaX,
      AG: x0 => x0.parentElement,
      AH: x0 => x0.readText(),
      AI: (x0,x1) => { x0.spellcheck = x1 },
      AJ: x0 => x0.signal,
      AK: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      AL: x0 => x0.ready,
      B: s => printToConsole(s),
      BB: b => !!b,
      BC: Function.prototype.call.bind(DataView.prototype.setUint16),
      BD: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      BE: (x0,x1) => x0.getPropertyValue(x1),
      BF: x0 => x0.key,
      BG: (x0,x1) => x0.querySelectorAll(x1),
      BH: x0 => x0.clipboard,
      BI: (x0,x1) => { x0.disabled = x1 },
      BJ: x0 => x0.abort(),
      BK: x0 => x0.send(),
      BL: x0 => x0.tracks,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CC: Function.prototype.call.bind(DataView.prototype.setUint8),
      CD: x0 => x0.tabIndex,
      CE: x0 => globalThis.parseFloat(x0),
      CF: x0 => x0.identifier,
      CG: (x0,x1) => x0.requestAnimationFrame(x1),
      CH: (x0,x1) => x0.writeText(x1),
      CI: x0 => globalThis.Module_soloud._setDataIsEnded(x0),
      CJ: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      CK: x0 => x0.type,
      CL: x0 => x0.close(),
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: (x0,x1) => x0.focus(x1),
      DC: Function.prototype.call.bind(DataView.prototype.setInt8),
      DD: (x0,x1) => x0.contains(x1),
      DE: (x0,x1) => x0.getComputedStyle(x1),
      DF: x0 => x0.touches,
      DG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      DH: x0 => x0.unlock(),
      DI: x0 => globalThis.Module_soloud._disposeSound(x0),
      DJ: x0 => x0.history,
      DK: x0 => x0.response,
      DL: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: () => ({}),
      EC: Function.prototype.call.bind(DataView.prototype.getInt8),
      ED: x0 => x0.activeElement,
      EE: x0 => x0.documentElement,
      EF: x0 => x0.pressure,
      EG: x0 => x0.now(),
      EH: (x0,x1) => x0.lock(x1),
      EI: x0 => globalThis.Module_soloud._malloc(x0),
      EJ: x0 => x0.href,
      EK: (x0,x1) => { x0.responseType = x1 },
      EL: (x0,x1) => x0.decode(x1),
      F: () => new Error().stack,
      FB: (o, p, v) => o[p] = v,
      FC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      FD: x0 => x0.parentNode,
      FE: x0 => x0.computedStyleMap(),
      FF: x0 => x0.tiltY,
      FG: x0 => x0.performance,
      FH: x0 => x0.orientation,
      FI: (x0,x1,x2) => globalThis.Module_soloud._addAudioDataStream(x0,x1,x2),
      FJ: x0 => x0.location,
      FK: x0 => x0.vendor,
      FL: x0 => x0.duration,
      G: s => JSON.stringify(s),
      GB: () => [],
      GC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      GD: x0 => x0.tagName,
      GE: (x0,x1) => x0.get(x1),
      GF: x0 => x0.tiltX,
      GG: (d, digits) => d.toFixed(digits),
      GH: (x0,x1) => x0.querySelector(x1),
      GI: x0 => globalThis.Module_soloud._free(x0),
      GJ: (handle) => clearInterval(handle),
      GK: x0 => x0.navigator,
      GL: x0 => x0.image,
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (a, i) => a.push(i),
      HC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      HD: x0 => x0.target,
      HE: (o, p) => p in o,
      HF: x0 => x0.pointerType,
      HG: x0 => x0.maxHeight,
      HH: (x0,x1) => { x0.title = x1 },
      HI: () => globalThis.Module_soloud.HEAPU8,
      HJ: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      HK: (x0,x1) => x0.getRandomValues(x1),
      HL: () => globalThis.window.ImageDecoder,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Int8Array(x0),
      IC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      ID: x0 => x0.clientY,
      IE: (x0,x1) => { x0.textContent = x1 },
      IF: x0 => x0.pointerId,
      IG: x0 => x0.maxWidth,
      IH: (x0,x1) => x0.vibrate(x1),
      II: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => globalThis.Module_soloud._setBufferStream(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      IJ: () => Date.now(),
      IK: () => globalThis.crypto,
      IL: x0 => x0.canvasKitMaximumSurfaces,
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      JD: x0 => x0.clientX,
      JE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      JF: x0 => x0.getCoalescedEvents(),
      JG: x0 => x0.minHeight,
      JH: x0 => x0.arrayBuffer(),
      JI: (x0,x1) => globalThis.Module_soloud.getValue(x0,x1),
      JJ: () => new Array(),
      JK: l => new DataView(new ArrayBuffer(l)),
      JL: (a, i) => a.splice(i, 1),
      K: o => o,
      KB: x0 => new Uint8Array(x0),
      KC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      KD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      KE: x0 => x0.matches,
      KF: (x0,x1) => x0.getModifierState(x1),
      KG: x0 => x0.minWidth,
      KH: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      KI: () => globalThis.Module_soloud._createWorkerInWasm(),
      KJ: (x0,x1) => new WebSocket(x0,x1),
      KK: (x0,x1,x2,x3) => x0.putImageData(x1,x2,x3),
      KL: a => a.pop(),
      L: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      LB: x0 => new Uint8ClampedArray(x0),
      LC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      LD: x0 => x0.getBoundingClientRect(),
      LE: (x0,x1) => x0.matchMedia(x1),
      LF: s => s.trimLeft(),
      LG: (x0,x1) => x0.removeProperty(x1),
      LH: x0 => x0.status,
      LI: x0 => globalThis.Module_soloud._setMixerOutputCallback(x0),
      LJ: x0 => x0.reason,
      LK: x0 => x0.arrayBuffer(),
      LL: x0 => x0.hostElement,
      M: x0 => x0.index,
      MB: x0 => new Int16Array(x0),
      MC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      MD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      ME: x0 => x0.matches,
      MF: s => s.toUpperCase(),
      MG: (x0,x1) => x0.add(x1),
      MH: (x0,x1) => x0.fetch(x1),
      MI: x0 => globalThis.Module_soloud._advanceMixerCaptureReadPosition(x0),
      MJ: x0 => x0.code,
      MK: (x0,x1) => x0.transferFromImageBitmap(x1),
      ML: x0 => x0.location,
      N: o => String(o),
      NB: x0 => new Uint16Array(x0),
      NC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      ND: s => new Date(s * 1000).getTimezoneOffset() * 60,
      NE: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      NF: x0 => x0.length,
      NG: x0 => x0.data,
      NH: x0 => x0.content,
      NI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      NJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      NK: x0 => x0.height,
      NL: (x0,x1) => x0.getModifierState(x1),
      O: o => o === undefined,
      OB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      OC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      OD: Date.now,
      OE: f => f.dartFunction,
      OF: x0 => x0.pop(),
      OG: (x0,x1) => { x0.scrollTop = x1 },
      OH: x0 => x0.document,
      OI: (x0,x1) => { x0.onmessage = x1 },
      OJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      OK: x0 => x0.width,
      OL: x0 => x0.metaKey,
      P: (x0,x1) => x0.exec(x1),
      PB: x0 => new Int32Array(x0),
      PC: (x0,x1) => x0.querySelector(x1),
      PD: (handle) => clearTimeout(handle),
      PE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PF: x0 => x0.flags,
      PG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      PH: () => typeof dartUseDateNowForTicks !== "undefined",
      PI: x0 => x0.data,
      PJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PK: x0 => x0.rasterEndMilliseconds,
      PL: x0 => x0.altKey,
      Q: (x0,x1) => { x0.lastIndex = x1 },
      QB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      QC: (x0,x1) => x0.item(x1),
      QD: (x0,x1) => x0.closest(x1),
      QE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      QF: (a, s) => a.join(s),
      QG: (x0,x1) => { x0.value = x1 },
      QH: () => Date.now(),
      QI: () => globalThis.Module_soloud.wasmWorker,
      QJ: (o, t) => typeof o === t,
      QK: x0 => x0.rasterStartMilliseconds,
      QL: x0 => x0.ctrlKey,
      R: o => o,
      RB: x0 => new Uint32Array(x0),
      RC: x0 => x0.length,
      RD: x0 => x0.bottom,
      RE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      RF: (x0,x1) => x0.error(x1),
      RG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      RH: () => 1000 * performance.now(),
      RI: () => globalThis.Module_soloud._getVisualizationEnabled(),
      RJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      RK: x0 => x0.imageBitmaps,
      RL: x0 => x0.isComposing,
      S: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      SB: x0 => new Float32Array(x0),
      SC: (x0,x1) => x0.querySelectorAll(x1),
      SD: x0 => x0.top,
      SE: (o, i) => o[i],
      SF: () => globalThis.console,
      SG: (x0,x1) => { x0.value = x1 },
      SH: x0 => new Uint8Array(x0),
      SI: (x0,x1,x2,x3,x4) => globalThis.Module_soloud._initEngine(x0,x1,x2,x3,x4),
      SJ: (x0,x1,x2) => x0.close(x1,x2),
      SK: (x0,x1) => { x0.height = x1 },
      SL: x0 => x0.code,
      T: o => o instanceof RegExp,
      TB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      TC: (x0,x1) => x0.getAttribute(x1),
      TD: x0 => x0.right,
      TE: o => o.length,
      TF: s => s.trimRight(),
      TG: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      TH: (x0,x1,x2) => x0.slice(x1,x2),
      TI: () => globalThis.Module_soloud._dispose(),
      TJ: (x0,x1) => x0.close(x1),
      TK: (x0,x1) => { x0.width = x1 },
      TL: x0 => x0.repeat,
      U: (string, times) => string.repeat(times),
      UB: x0 => new Float64Array(x0),
      UC: x0 => x0.remove(),
      UD: x0 => x0.left,
      UE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      UF: x0 => x0.blur(),
      UG: x0 => x0.value,
      UH: (x0,x1) => x0.decode(x1),
      UI: () => globalThis.Module_soloud._stopMixerCapture(),
      UJ: x0 => x0.close(),
      UK: x0 => x0.convertToBlob(),
      UL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      V: o => o,
      VB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      VC: (x0,x1) => x0.appendChild(x1),
      VD: x0 => x0.clientY,
      VE: x0 => x0.language,
      VF: x0 => x0.button,
      VG: x0 => x0.selectionDirection,
      VH: (x0,x1) => x0.adoptText(x1),
      VI: () => globalThis.Module_soloud._isMixerCaptureRunning(),
      VJ: (x0,x1) => x0.send(x1),
      VK: (x0,x1,x2) => new ImageData(x0,x1,x2),
      VL: x0 => x0.userAgent,
      W: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      WB: x0 => new ArrayBuffer(x0),
      WC: (x0,x1) => x0.append(x1),
      WD: x0 => x0.clientX,
      WE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      WF: x0 => x0.innerHeight,
      WG: x0 => x0.selectionStart,
      WH: x0 => x0.first(),
      WI: () => globalThis.Module_soloud._isInited(),
      WJ: x0 => x0.readyState,
      WK: (x0,x1) => x0.getContext(x1),
      WL: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      X: x0 => x0.dotAll,
      XB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      XC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      XD: x0 => x0.changedTouches,
      XE: () => globalThis.window.FinalizationRegistry,
      XF: x0 => x0.innerWidth,
      XG: x0 => x0.selectionEnd,
      XH: x0 => x0.next(),
      XI: (map, o, v) => map.set(o, v),
      XJ: (x0,x1) => { x0.binaryType = x1 },
      XK: (x0,x1) => new OffscreenCanvas(x0,x1),
      XL: (x0,x1) => x0.canShare(x1),
      Y: x0 => x0.unicode,
      YB: (x0,x1,x2) => new DataView(x0,x1,x2),
      YC: x0 => x0.style,
      YD: x0 => x0.offsetY,
      YE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      YF: x0 => x0.height,
      YG: x0 => x0.value,
      YH: x0 => x0.current(),
      YI: () => new WeakMap(),
      YJ: x0 => new BroadcastChannel(x0),
      YK: x0 => x0.allocationSize(),
      YL: (x0,x1) => x0.share(x1),
      Z: x0 => x0.ignoreCase,
      ZB: (o, p) => o[p],
      ZC: x0 => x0.debugShowSemanticsNodes,
      ZD: x0 => x0.offsetX,
      ZE: x0 => new window.FinalizationRegistry(x0),
      ZF: x0 => x0.width,
      ZG: x0 => x0.selectionDirection,
      ZH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      ZI: (map, o) => map.get(o),
      ZJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      ZK: (x0,x1) => x0.copyTo(x1),
      ZL: x0 => x0.message,
      a: x0 => x0.multiline,
      aB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      aC: (x0,x1) => x0.warn(x1),
      aD: x0 => x0.type,
      aE: (x0,x1) => x0.unregister(x1),
      aF: x0 => x0.clientHeight,
      aG: x0 => x0.selectionStart,
      aH: x0 => x0.v8BreakIterator,
      aI: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      aJ: x0 => x0.close(),
      aK: (x0,x1) => { x0.height = x1 },
      aL: (o, a) => o + a,
      b: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      bB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      bC: x0 => x0.console,
      bD: x0 => x0.maxTouchPoints,
      bE: (x0,x1) => x0.contains(x1),
      bF: x0 => x0.clientWidth,
      bG: x0 => x0.selectionEnd,
      bH: () => globalThis.Intl,
      bI: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      bJ: (x0,x1) => x0.postMessage(x1),
      bK: (x0,x1) => { x0.width = x1 },
      bL: x0 => x0.children,
      c: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      cB: o => o.byteOffset,
      cC: () => globalThis.window,
      cD: x0 => x0.platform,
      cE: (s) => +s,
      cF: (x0,x1) => { x0.content = x1 },
      cG: x0 => x0.keyCode,
      cH: (x0,x1) => x0.segment(x1),
      cI: (x0,x1) => x0.removeItem(x1),
      cJ: (x0,x1) => { x0.onmessage = x1 },
      cK: (x0,x1) => x0.toDataURL(x1),
      cL: (x0,x1,x2) => ({files: x0,title: x1,text: x2}),
      d: (x0,x1) => x0.didCreateEngineInitializer(x1),
      dB: o => o.buffer,
      dC: (o, c) => o instanceof c,
      dD: x0 => x0.body,
      dE: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      dF: (x0,x1) => { x0.name = x1 },
      dG: (x0,x1) => x0.scrollIntoView(x1),
      dH: x0 => x0.index,
      dI: x0 => x0.localStorage,
      dJ: x0 => x0.debugSkipFontRetryDelay,
      dK: (x0,x1,x2,x3) => x0.drawImage(x1,x2,x3),
      dL: (x0,x1) => ({files: x0,text: x1}),
      e: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eB: Function.prototype.call.bind(DataView.prototype.getUint8),
      eC: (string, token) => string.split(token),
      eD: () => globalThis.document,
      eE: s => s.trim(),
      eF: x0 => x0.head,
      eG: x0 => x0.multiViewEnabled,
      eH: x0 => x0.next(),
      eI: () => globalThis.window,
      eJ: (x0,x1,x2) => x0.set(x1,x2),
      eK: (x0,x1) => x0.getContext(x1),
      eL: (x0,x1) => ({files: x0,title: x1}),
      f: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      fB: (b, o) => new DataView(b, o),
      fC: o => o instanceof Array,
      fD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      fE: x0 => x0.classList,
      fF: (x0,x1) => x0.removeChild(x1),
      fG: (x0,x1) => x0.replaceWith(x1),
      fH: x0 => x0.value,
      fI: (x0,x1) => x0.key(x1),
      fJ: x0 => x0.fontFallbackBaseUrl,
      fK: x0 => x0.displayHeight,
      fL: x0 => ({files: x0}),
      g: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      gB: (b, o, l) => new DataView(b, o, l),
      gC: (a, i) => a[i],
      gD: x0 => x0.hasFocus(),
      gE: x0 => x0.preventDefault(),
      gF: x0 => x0.firstChild,
      gG: (x0,x1) => { x0.type = x1 },
      gH: x0 => x0.done,
      gI: x0 => x0.length,
      gJ: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => globalThis.Module_soloud._playWithLoopPoints(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      gK: x0 => x0.format,
      gL: (x0,x1) => ({title: x0,text: x1}),
      h: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      hB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      hC: a => a.length,
      hD: x0 => x0.relatedTarget,
      hE: x0 => x0.parent,
      hF: x0 => x0.viewConstraints,
      hG: (x0,x1) => { x0.className = x1 },
      hH: (o, m, a) => o[m].apply(o, a),
      hI: (x0,x1,x2) => x0.setItem(x1,x2),
      hJ: x0 => ({type: x0}),
      hK: x0 => x0.displayWidth,
      hL: () => ({}),
      i: x0 => new Promise(x0),
      iB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      iC: (x0,x1) => x0.test(x1),
      iD: x0 => x0.shiftKey,
      iE: x0 => x0.timeStamp,
      iF: x0 => x0.hostElement,
      iG: (x0,x1) => { x0.tabIndex = x1 },
      iH: x0 => x0.iterator,
      iI: (x0,x1) => x0.getItem(x1),
      iJ: (x0,x1) => new Blob(x0,x1),
      iK: (x0,x1) => x0.revokeObjectURL(x1),
      iL: (x0,x1,x2) => new File(x0,x1,x2),
      j: (x0,x1,x2) => x0.call(x1,x2),
      jB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      jC: x0 => x0.userAgent,
      jD: (decoder, codeUnits) => decoder.decode(codeUnits),
      jE: (x0,x1) => x0.hasAttribute(x1),
      jF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      jG: (x0,x1) => { x0.name = x1 },
      jH: () => globalThis.Symbol,
      jI: () => new AbortController(),
      jJ: x0 => globalThis.URL.createObjectURL(x0),
      jK: (x0,x1) => { x0.src = x1 },
      jL: (x0,x1) => { x0.type = x1 },
      k: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      kB: (t, s) => t.set(s),
      kC: x0 => x0.navigator,
      kD: () => new TextDecoder("utf-8", {fatal: true}),
      kE: x0 => x0.buttons,
      kF: x0 => ({runApp: x0}),
      kG: (x0,x1) => { x0.placeholder = x1 },
      kH: (x0,x1) => new Intl.Segmenter(x0,x1),
      kI: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      kJ: (x0,x1) => x0.append(x1),
      kK: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      kL: x0 => x0.length,
      l: x0 => new Array(x0),
      lB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      lC: Function.prototype.call.bind(String.prototype.toLowerCase),
      lD: () => new TextDecoder("utf-8", {fatal: false}),
      lE: x0 => x0.ctrlKey,
      lF: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      lG: (x0,x1) => { x0.autocomplete = x1 },
      lH: x0 => x0.Segmenter,
      lI: (x0,x1) => globalThis.fetch(x0,x1),
      lJ: x0 => x0.click(),
      lK: x0 => x0.naturalHeight,
      lL: x0 => x0.getReader(),
      m: o => [o],
      mB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      mC: Object.is,
      mD: (a, i, v) => a[i] = v,
      mE: x0 => x0.y,
      mF: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      mG: (x0,x1) => { x0.name = x1 },
      mH: x0 => x0.buffer,
      mI: (x0,x1) => x0.get(x1),
      mJ: x0 => x0.remove(),
      mK: x0 => x0.naturalWidth,
      mL: x0 => x0.value,
      n: (o0, o1) => [o0, o1],
      nB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      nC: x0 => x0.vendor,
      nD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      nE: x0 => x0.x,
      nF: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      nG: (x0,x1) => { x0.placeholder = x1 },
      nH: x0 => x0.wasmMemory,
      nI: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      nJ: x0 => globalThis.URL.revokeObjectURL(x0),
      nK: x0 => x0.decode(),
      nL: x0 => x0.done,
      o: (o0, o1, o2) => [o0, o1, o2],
      oB: Function.prototype.call.bind(DataView.prototype.getUint32),
      oC: (x0,x1) => x0.createTextNode(x1),
      oD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      oE: x0 => x0.scrollTop,
      oF: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      oG: (x0,x1) => { x0.action = x1 },
      oH: () => globalThis.window._flutter_skwasmInstance,
      oI: (x0,x1) => x0.forEach(x1),
      oJ: x0 => x0.body,
      oK: (x0,x1) => { x0.decoding = x1 },
      oL: x0 => x0.read(),
      p: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      pB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      pC: (x0,x1) => { x0.id = x1 },
      pD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      pE: x0 => x0.offsetTop,
      pF: x0 => x0.history,
      pG: (x0,x1) => { x0.method = x1 },
      pH: () => new TextDecoder(),
      pI: x0 => x0.name,
      pJ: () => globalThis.document,
      pK: (x0,x1) => { x0.crossOrigin = x1 },
      pL: x0 => x0.body,
      q: (x0,x1,x2) => { x0[x1] = x2 },
      qB: Function.prototype.call.bind(DataView.prototype.getInt32),
      qC: (x0,x1) => { x0.nonce = x1 },
      qD: x0 => x0.visibilityState,
      qE: x0 => x0.scrollLeft,
      qF: x0 => x0.search,
      qG: (x0,x1) => { x0.noValidate = x1 },
      qH: (x0,x1,x2) => x0.insertBefore(x1,x2),
      qI: x0 => x0.statusText,
      qJ: (x0,x1) => { x0.display = x1 },
      qK: (x0,x1) => x0.createObjectURL(x1),
      qL: x0 => x0.assetBase,
      r: (o, p) => o[p],
      rB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      rC: x0 => x0.nonce,
      rD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      rE: x0 => x0.offsetLeft,
      rF: x0 => x0.location,
      rG: (x0,x1) => x0.removeAttribute(x1),
      rH: x0 => x0.id,
      rI: x0 => x0.url,
      rJ: x0 => x0.style,
      rK: x0 => x0.URL,
      rL: x0 => x0.loader,
      s: () => globalThis,
      sB: o => o instanceof Uint16Array,
      sC: () => globalThis.window.flutterConfiguration,
      sD: x0 => x0.disconnect(),
      sE: x0 => x0.offsetParent,
      sF: x0 => x0.pathname,
      sG: x0 => x0.isConnected,
      sH: x0 => x0.offsetHeight,
      sI: x0 => x0.status,
      sJ: (x0,x1) => { x0.download = x1 },
      sK: x0 => new Blob(x0),
      sL: () => globalThis._flutter,
      t: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tB: Function.prototype.call.bind(DataView.prototype.getUint16),
      tC: (x0,x1) => x0.attachShadow(x1),
      tD: x0 => new Intl.Locale(x0),
      tE: (x0,x1) => x0[x1],
      tF: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      tG: x0 => x0.click(),
      tH: x0 => x0.offsetWidth,
      tI: x0 => x0.getReader(),
      tJ: (x0,x1) => { x0.href = x1 },
      tK: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      u: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      uB: o => o instanceof Int16Array,
      uC: (x0,x1) => x0.createElement(x1),
      uD: x0 => x0.region,
      uE: (o, p, r) => o.replace(p, () => r),
      uF: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      uG: (x0,x1) => x0.getElementsByClassName(x1),
      uH: x0 => x0.stopPropagation(),
      uI: x0 => x0.read(),
      uJ: (x0,x1) => x0.createElement(x1),
      uK: x0 => new window.ImageDecoder(x0),
      v: (x0,x1) => ({addView: x0,removeView: x1}),
      vB: Function.prototype.call.bind(DataView.prototype.getInt16),
      vC: x0 => x0.scale,
      vD: x0 => x0.script,
      vE: (o, p, r) => o.replaceAll(p, () => r),
      vF: o => Object.keys(o),
      vG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      vH: x0 => x0.disabled,
      vI: x0 => x0.value,
      vJ: o => o.byteLength,
      vK: x0 => x0.name,
      w: (l, r) => l === r,
      wB: o => o instanceof Uint8ClampedArray,
      wC: x0 => x0.visualViewport,
      wD: x0 => x0.language,
      wE: x0 => x0.deltaMode,
      wF: x0 => x0.state,
      wG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      wH: (x0,x1) => { x0.min = x1 },
      wI: x0 => x0.done,
      wJ: () => new FileReader(),
      wK: x0 => x0.repetitionCount,
      x: x0 => x0.random(),
      xB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      xC: x0 => x0.devicePixelRatio,
      xD: x0 => x0.languages,
      xE: x0 => x0.deltaY,
      xF: x0 => x0.hash,
      xG: (x0,x1) => x0.dispatchEvent(x1),
      xH: (x0,x1) => { x0.max = x1 },
      xI: x0 => x0.cancel(),
      xJ: (x0,x1) => x0.readAsArrayBuffer(x1),
      xK: x0 => x0.frameCount,
      y: () => globalThis.Math,
      yB: Function.prototype.call.bind(DataView.prototype.setInt32),
      yC: x0 => x0.height,
      yD: (x0,x1) => x0.observe(x1),
      yE: x0 => x0.deltaX,
      yF: x0 => x0.state,
      yG: (x0,x1) => x0.createEvent(x1),
      yH: (x0,x1) => { x0.disabled = x1 },
      yI: x0 => x0.body,
      yJ: x0 => x0.result,
      yK: x0 => x0.selectedTrack,
      z: (x0,x1) => x0.prepend(x1),
      zB: Function.prototype.call.bind(DataView.prototype.setUint32),
      zC: x0 => x0.width,
      zD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      zE: x0 => x0.wheelDeltaY,
      zF: (x0,x1) => x0.go(x1),
      zG: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      zH: (x0,x1) => { x0.scrollLeft = x1 },
      zI: x0 => x0.headers,
      zJ: () => new XMLHttpRequest(),
      zK: x0 => x0.completed,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
