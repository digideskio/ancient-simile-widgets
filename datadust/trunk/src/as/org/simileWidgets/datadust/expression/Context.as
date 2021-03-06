package org.simileWidgets.datadust.expression {
    import org.simileWidgets.datadust.DateUtilities;
    
    public class Context {
        protected var _parent:Context;
        protected var _map:Object = {};
        
        public function Context(parent:Context) {
            _parent = parent;
        }
        
        public function getIdentifier(name:String):* {
            return _map.hasOwnProperty(name) ? _map[name] : (_parent != null ? _parent.getIdentifier(name) : null);
        }
        
        public function setIdentifier(name:String, value:*):void {
            _map[name] = value;
        }
        
        static public function createDefaultContext():Context {
            var ctx:Context = new Context(null);
            ctx.setIdentifier("null", null);
            ctx.setIdentifier("true", true);
            ctx.setIdentifier("false", false);
            ctx.setIdentifier("pi", Math.PI);
            ctx.setIdentifier("e", Math.E);
            
            ctx.setIdentifier("round", Math.round);
            ctx.setIdentifier("floor", Math.floor);
            ctx.setIdentifier("ceil", Math.ceil);
            ctx.setIdentifier("abs", Math.abs);
            
            ctx.setIdentifier("sin", Math.sin);
            ctx.setIdentifier("cos", Math.cos);
            ctx.setIdentifier("tan", Math.tan);
            ctx.setIdentifier("asin", Math.asin);
            ctx.setIdentifier("acos", Math.acos);
            ctx.setIdentifier("atan", Math.atan);
            ctx.setIdentifier("atan2", Math.atan2);
            
            ctx.setIdentifier("exp", Math.exp);
            ctx.setIdentifier("ln", Math.log);
            ctx.setIdentifier("sqrt", Math.sqrt);
            ctx.setIdentifier("power", Math.pow);
            
            ctx.setIdentifier("min", createAccumulator(Math.min, null));
            ctx.setIdentifier("max", createAccumulator(Math.max, null));
            ctx.setIdentifier("sum", createAccumulator(function(a:Number, b:Number):Number { return a + b; }, 0));
            ctx.setIdentifier("product", createAccumulator(function(a:Number, b:Number):Number { return a * b; }, 1));
            
            ctx.setIdentifier("length", function(x:*):Number {
                if (x != null) {
                    if (x is Array) {
                        return x.length;
                    } else if (x is String) {
                        return x.length;
                    }
                }
                return 0;
            });
            
            ctx.setIdentifier("date", DateUtilities.parseIso8601DateTime);
            
            ctx.setIdentifier("lower", function(s:String):String {
                return s == null ? null : s.toLowerCase();
            });
            ctx.setIdentifier("upper", function(s:String):String {
                return s == null ? null : s.toUpperCase();
            });

            ctx.setIdentifier("and", function(... args):Boolean {
                var r:Boolean = true;
                for (var i:int = 0; r && i < args.length; i++) {
                    var arg:* = args[i];
                    r = r && Boolean(arg);
                }
                return r;
            });
            ctx.setIdentifier("or", function(... args):Boolean {
                var r:Boolean = false;
                for (var i:int = 0; !r && i < args.length; i++) {
                    var arg:* = args[i];
                    r = r || Boolean(arg);
                }
                return r;
            });
            ctx.setIdentifier("nor", function(... args):Boolean {
                var r:Boolean = false;
                for (var i:int = 0; !r && i < args.length; i++) {
                    var arg:* = args[i];
                    r = r || Boolean(arg);
                }
                return !r;
            });
            ctx.setIdentifier("xor", function(... args):Boolean {
                var c:int = 0;
                for (var i:int = 0; i < args.length; i++) {
                    var arg:* = args[i];
                    if (Boolean(arg)) {
                        c++;
                    }
                }
                return c == 1;
            });
            ctx.setIdentifier("not", function(b:Boolean):Boolean {
                return !b;
            });
            
            return ctx;
        }
        
        static protected function createAccumulator(f:Function, start:*):Function {
            return function(... args):Number {
                var has:Boolean = false;
                var r:* = start;
                
                for (var i:int = 0; i < args.length; i++) {
                    var arg:* = args[i];
                    if (arg is Array) {
                        for (var j:int = 0; j < arg.length; j++) {
                            var elmt:* = arg[j];
                            if (has) {
                                r = f(r, arg);
                            } else {
                                r = arg;
                                has = true;
                            }
                        }
                    } else {
                        if (has) {
                            r = f(r, arg);
                        } else {
                            r = arg;
                            has = true;
                        }
                    }
                }
                return r;
            };
        }
        
    }
}
