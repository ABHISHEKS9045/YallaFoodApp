package com.iposprinter.printertestdemo.Utils;

/**
 * Created by Administrator on 2017/7/25.
 */
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import java.lang.ref.SoftReference;

/**
 * Created by liuchangfa on 2016.
 * handler创建工具，利用软引用防止内存泄露
 */

public class HandlerUtils {

    private static final long serialVersionUID = 0L;

    /**
     * 在使用handler的地方继承此接口，然后把实例化的引用给实例化的handler
     */
    public interface IHandlerIntent {
        void handlerIntent(Message message);
    }

    public static final class MyHandler extends Handler
    {
        private SoftReference<IHandlerIntent> owner;

        public MyHandler(IHandlerIntent t) {
            owner = new SoftReference<>(t);
        }

        public MyHandler(Looper looper, IHandlerIntent t) {
            super(looper);
            owner = new SoftReference<>(t);
        }

        @Override
        public void handleMessage(Message msg) {
            IHandlerIntent t = owner.get();
            if (null != t) {
                t.handlerIntent(msg);
            }
        }
    }
}
