ljf-com
=======

Module for using Microsoft COM with LuaJIT FFI


```lua
local com = require 'extern.mswindows.com'
com.def {

  {'IMyInterface';
    methods = {
      {'NormalMethod', 'int param1, int param2, int param3'};
      {ret='void', 'MethodWithCustomReturnType'}; -- if not defined, the return type is int/HRESULT
    };
    iid = "00000000-0000-0000-0000000000000001";
  };

  {'IExtendedInterface', inherits='IMyInterface'; -- if not defined, the interface inherits from IUnknown
    methods = {
      {'ExtendedMethod'};
    };
    iid = "00000000-0000-0000-0000000000000002";
  };

}
```

Note: The module extern.mswindows is only a minimal slice of a general-purpose Win32 binding library, to support extern.mswindows.com. It should not be taken too seriously in its own right.
