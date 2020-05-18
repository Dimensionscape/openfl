package openfl.display;

import openfl.geom.Matrix;
import openfl.geom._Matrix;
import openfl.geom.Rectangle;
import openfl.events.MouseEvent;
import openfl.media.SoundTransform;
import openfl.ui.MouseCursor;
import openfl.Vector;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:noCompletion
class _SimpleButton extends _InteractiveObject
{
	public var downState(get, set):DisplayObject;
	public var enabled:Bool;
	public var hitTestState(get, set):DisplayObject;
	public var overState(get, set):DisplayObject;
	public var soundTransform(get, set):SoundTransform;
	public var trackAsMenu:Bool;
	public var upState(get, set):DisplayObject;
	public var useHandCursor:Bool;

	private static var __constructor:SimpleButton->Void;

	public var __currentState(default, set):DisplayObject;
	public var __downState:DisplayObject;
	public var __hitTestState:DisplayObject;
	public var __ignoreEvent:Bool;
	public var __overState:DisplayObject;
	public var __previousStates:Vector<DisplayObject>;
	public var __soundTransform:SoundTransform;
	public var __upState:DisplayObject;

	private var simpleButton:SimpleButton;

	public function new(simpleButton:SimpleButton, upState:DisplayObject = null, overState:DisplayObject = null, downState:DisplayObject = null,
			hitTestState:DisplayObject = null)
	{
		this.simpleButton = simpleButton;

		super(simpleButton);

		__type = SIMPLE_BUTTON;

		enabled = true;
		trackAsMenu = false;
		useHandCursor = true;

		__upState = (upState != null) ? upState : new DisplayObject();
		__overState = overState;
		__downState = downState;
		this.hitTestState = (hitTestState != null) ? hitTestState : new DisplayObject();

		addEventListener(MouseEvent.MOUSE_DOWN, __this_onMouseDown);
		addEventListener(MouseEvent.MOUSE_OUT, __this_onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, __this_onMouseOver);
		addEventListener(MouseEvent.MOUSE_UP, __this_onMouseUp);

		__tabEnabled = true;
		__currentState = __upState;

		if (__constructor != null)
		{
			var method = __constructor;
			__constructor = null;

			method(this.simpleButton);
		}
	}

	public override function __getBounds(rect:Rectangle, matrix:Matrix):Void
	{
		super.__getBounds(rect, matrix);

		var childWorldTransform = _Matrix.__pool.get();

		_DisplayObject.__calculateAbsoluteTransform((__currentState._ : _DisplayObject).__transform, matrix, childWorldTransform);

		(__currentState._ : _DisplayObject).__getBounds(rect, childWorldTransform);

		_Matrix.__pool.release(childWorldTransform);
	}

	public override function __getRenderBounds(rect:Rectangle, matrix:Matrix):Void
	{
		if (__scrollRect != null)
		{
			super.__getRenderBounds(rect, matrix);
			return;
		}
		else
		{
			super.__getBounds(rect, matrix);
		}

		var childWorldTransform = _Matrix.__pool.get();

		_DisplayObject.__calculateAbsoluteTransform((__currentState._ : _DisplayObject).__transform, matrix, childWorldTransform);

		(__currentState._ : _DisplayObject).__getRenderBounds(rect, childWorldTransform);

		_Matrix.__pool.release(childWorldTransform);
	}

	public override function __getCursor():MouseCursor
	{
		return (useHandCursor && !__ignoreEvent && enabled) ? BUTTON : null;
	}

	public override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool
	{
		var hitTest = false;

		if (hitTestState != null)
		{
			if ((hitTestState._ : _DisplayObject).__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject))
			{
				if (stack != null)
				{
					if (stack.length == 0)
					{
						stack[0] = hitObject;
					}
					else
					{
						stack[stack.length - 1] = hitObject;
					}
				}

				hitTest = (!interactiveOnly || mouseEnabled);
			}
		}
		else if (__currentState != null)
		{
			if (!hitObject.visible
				|| __isMask
				|| (interactiveOnly && !mouseEnabled)
				|| (mask != null && !(mask._ : _DisplayObject).__hitTestMask(x, y)))
			{
				hitTest = false;
			}
			else if ((__currentState._ : _DisplayObject).__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject))
			{
				hitTest = interactiveOnly;
			}
		}

		// TODO: Better fix?
		// (this is caused by the "hitObject" logic in hit testing)

		if (stack != null)
		{
			while (stack.length > 1 && stack[stack.length - 1] == stack[stack.length - 2])
			{
				stack.pop();
			}
		}

		return hitTest;
	}

	public override function __hitTestMask(x:Float, y:Float):Bool
	{
		var hitTest = false;

		if ((__currentState._ : _DisplayObject).__hitTestMask(x, y))
		{
			hitTest = true;
		}

		return hitTest;
	}

	public override function __setTransformDirty(force:Bool = false):Void
	{
		// inline super.__setTransformDirty(force);
		__transformDirty = true;

		if (__currentState != null)
		{
			(__currentState._ : _DisplayObject).__setTransformDirty(force);
		}

		if (hitTestState != null && hitTestState != __currentState)
		{
			(hitTestState._ : _DisplayObject).__setTransformDirty(force);
		}
	}

	public override function __update(transformOnly:Bool, updateChildren:Bool):Void
	{
		__updateSingle(transformOnly, updateChildren);

		if (updateChildren)
		{
			if (__currentState != null)
			{
				(__currentState._ : _DisplayObject).__update(transformOnly, true);
			}

			if (hitTestState != null && hitTestState != __currentState)
			{
				(hitTestState._ : _DisplayObject).__update(transformOnly, true);
			}
		}
	}

	// Getters & Setters
	private function get_downState():DisplayObject
	{
		return __downState;
	}

	private function set_downState(downState:DisplayObject):DisplayObject
	{
		if (__downState != null && __currentState == __downState)
		{
			__currentState = __downState;
		}

		return __downState = downState;
	}

	private function get_hitTestState():DisplayObject
	{
		return __hitTestState;
	}

	private function set_hitTestState(hitTestState:DisplayObject):DisplayObject
	{
		if (__hitTestState != null && __hitTestState != hitTestState)
		{
			if (__hitTestState != downState && __hitTestState != upState && __hitTestState != overState)
			{
				(__hitTestState._ : _DisplayObject).__renderParent = null;
				(__hitTestState._ : _DisplayObject).__setTransformDirty();
			}
		}

		if (hitTestState != null)
		{
			(__hitTestState._ : _DisplayObject).__renderParent = this.simpleButton;
			(__hitTestState._ : _DisplayObject).__setTransformDirty();
			(__hitTestState._ : _DisplayObject).__setRenderDirty();
		}

		return __hitTestState = hitTestState;
	}

	private function get_overState():DisplayObject
	{
		return __overState;
	}

	private function set_overState(overState:DisplayObject):DisplayObject
	{
		if (__overState != null && __currentState == __overState)
		{
			__currentState = overState;
		}

		return __overState = overState;
	}

	private function get_soundTransform():SoundTransform
	{
		if (__soundTransform == null)
		{
			__soundTransform = new SoundTransform();
		}

		return new SoundTransform(__soundTransform.volume, __soundTransform.pan);
	}

	private function set_soundTransform(value:SoundTransform):SoundTransform
	{
		__soundTransform = new SoundTransform(value.volume, value.pan);
		return value;
	}

	private function get_upState():DisplayObject
	{
		return __upState;
	}

	private function set_upState(upState:DisplayObject):DisplayObject
	{
		if (__upState != null && __currentState == __upState)
		{
			__currentState = upState;
		}

		return __upState = upState;
	}

	private function set___currentState(value:DisplayObject):DisplayObject
	{
		if (__currentState != null && __currentState != hitTestState)
		{
			(__currentState._ : _DisplayObject).__renderParent = null;
			(__currentState._ : _DisplayObject).__setTransformDirty();
		}

		if (value != null && value.parent != null)
		{
			value.parent.removeChild(value);
		}

		// #if (openfl_html5 && dom)
		#if openfl_html5
		if (_DisplayObject.__supportDOM && __previousStates == null)
		{
			__previousStates = new Vector<DisplayObject>();
		}
		#end

		if (value != __currentState)
		{
			// #if (openfl_html5 && dom)
			#if openfl_html5
			if (_DisplayObject.__supportDOM)
			{
				if (__currentState != null)
				{
					(__currentState._ : _DisplayObject).__setStageReferences(null);
					__previousStates.push(__currentState);
				}

				var index = __previousStates.indexOf(value);

				if (index > -1)
				{
					__previousStates.splice(index, 1);
				}
			}
			#end

			if (value != null)
			{
				(value._ : _DisplayObject).__renderParent = this.simpleButton;
				(value._ : _DisplayObject).__setTransformDirty();
				(value._ : _DisplayObject).__setRenderDirty();
			}

			__localBoundsDirty = true;
			__setRenderDirty();
		}

		__currentState = value;

		return value;
	}

	// Event Handlers
	private function __this_onMouseDown(event:MouseEvent):Void
	{
		if (enabled)
		{
			__currentState = downState;
		}
	}

	private function __this_onMouseOut(event:MouseEvent):Void
	{
		__ignoreEvent = false;

		if (upState != __currentState)
		{
			__currentState = upState;
		}
	}

	private function __this_onMouseOver(event:MouseEvent):Void
	{
		if (event.buttonDown)
		{
			__ignoreEvent = true;
		}

		if (overState != __currentState && overState != null && !__ignoreEvent && enabled)
		{
			__currentState = overState;
		}
	}

	private function __this_onMouseUp(event:MouseEvent):Void
	{
		__ignoreEvent = false;

		if (enabled && overState != null)
		{
			__currentState = overState;
		}
		else
		{
			__currentState = upState;
		}
	}
}