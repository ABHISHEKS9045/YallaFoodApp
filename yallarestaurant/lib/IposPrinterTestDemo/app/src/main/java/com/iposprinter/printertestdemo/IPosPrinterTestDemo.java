package com.iposprinter.printertestdemo;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.Random;

import android.support.v7.widget.LinearLayoutCompat;
import android.view.WindowManager;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.appindexing.Thing;
import com.google.android.gms.common.api.GoogleApiClient;
import com.iposprinter.iposprinterservice.*;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.iposprinter.printertestdemo.Utils.ButtonDelayUtils;
import com.iposprinter.printertestdemo.Utils.BytesUtil;
import com.iposprinter.printertestdemo.Utils.HandlerUtils;
import static com.iposprinter.printertestdemo.Utils.PrintContentsExamples.customCHR;
import static com.iposprinter.printertestdemo.Utils.PrintContentsExamples.customCHZ1;
import static com.iposprinter.printertestdemo.Utils.PrintContentsExamples.Text;
import static com.iposprinter.printertestdemo.Utils.PrintContentsExamples.Elemo;
import static com.iposprinter.printertestdemo.Utils.PrintContentsExamples.Baidu;
import static com.iposprinter.printertestdemo.MemInfo.bitmapRecycle;

public class IPosPrinterTestDemo extends Activity implements OnClickListener {

    private static final String TAG = "IPosPrinterTestDemo";
    /* Demo 版本号*/
    private static final String VERSION = "V1.1.1";


    private Button b_barcode, b_pic, b_qcode, b_self, b_text, b_table, b_init, b_lines, b_test, b_testall;
    private Button b_erlmo, b_meituan, b_baidu, b_query, b_bytes, b_length, b_continu, b_koubei;
    private Button b_runpaper, b_motor, b_demo, b_wave, b_error, b_loop;

    /*定义打印机状态*/
    private final int PRINTER_NORMAL = 0;
    private final int PRINTER_PAPERLESS = 1;
    private final int PRINTER_THP_HIGH_TEMPERATURE = 2;
    private final int PRINTER_MOTOR_HIGH_TEMPERATURE = 3;
    private final int PRINTER_IS_BUSY = 4;
    private final int PRINTER_ERROR_UNKNOWN = 5;
    /*打印机当前状态*/
    private int printerStatus = 0;

    /*定义状态广播*/
    private final String PRINTER_NORMAL_ACTION = "com.iposprinter.iposprinterservic e.NORMAL_ACTION";
    private final String PRINTER_PAPERLESS_ACTION = "com.iposprinter.iposprinterservice.PAPERLESS_ACTION";
    private final String PRINTER_PAPEREXISTS_ACTION = "com.iposprinter.iposprinterservice.PAPEREXISTS_ACTION";
    private final String PRINTER_THP_HIGHTEMP_ACTION = "com.iposprinter.iposprinterservice.THP_HIGHTEMP_ACTION";
    private final String PRINTER_THP_NORMALTEMP_ACTION = "com.iposprinter.iposprinterservice.THP_NORMALTEMP_ACTION";
    private final String PRINTER_MOTOR_HIGHTEMP_ACTION = "com.iposprinter.iposprinterservice.MOTOR_HIGHTEMP_ACTION";
    private final String PRINTER_BUSY_ACTION = "com.iposprinter.iposprinterservice.BUSY_ACTION";
    private final String PRINTER_CURRENT_TASK_PRINT_COMPLETE_ACTION = "com.iposprinter.iposprinterservice.CURRENT_TASK_PRINT_COMPLETE_ACTION";
    private final String GET_CUST_PRINTAPP_PACKAGENAME_ACTION = "android.print.action.CUST_PRINTAPP_PACKAGENAME";

    /*定义消息*/
    private final int MSG_TEST = 1;
    private final int MSG_IS_NORMAL = 2;
    private final int MSG_IS_BUSY = 3;
    private final int MSG_PAPER_LESS = 4;
    private final int MSG_PAPER_EXISTS = 5;
    private final int MSG_THP_HIGH_TEMP = 6;
    private final int MSG_THP_TEMP_NORMAL = 7;
    private final int MSG_MOTOR_HIGH_TEMP = 8;
    private final int MSG_MOTOR_HIGH_TEMP_INIT_PRINTER = 9;
    private final int MSG_CURRENT_TASK_PRINT_COMPLETE = 10;

    /*循环打印类型*/
    private final int MULTI_THREAD_LOOP_PRINT = 1;
    private final int INPUT_CONTENT_LOOP_PRINT = 2;
    private final int DEMO_LOOP_PRINT = 3;
    private final int PRINT_DRIVER_ERROR_TEST = 4;
    private final int DEFAULT_LOOP_PRINT = 0;

    //循环打印标志位
    private int loopPrintFlag = DEFAULT_LOOP_PRINT;
    private byte loopContent = 0x00;
    private int printDriverTestCount = 0;


    private TextView info;
    private IPosPrinterService mIPosPrinterService;
    private IPosPrinterCallback callback = null;

    private Random random = new Random();
    private HandlerUtils.MyHandler handler;
    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    private GoogleApiClient client;

    private void setButtonEnable(boolean flag) {
        b_barcode.setEnabled(flag);
        b_pic.setEnabled(flag);
        b_qcode.setEnabled(flag);
        // b_self.setEnabled(flag);
        b_text.setEnabled(flag);
        b_table.setEnabled(flag);
        //b_init.setEnabled(flag);
        b_lines.setEnabled(flag);
        b_test.setEnabled(flag);
        //b_testall.setEnabled(flag);
        b_erlmo.setEnabled(flag);
        b_meituan.setEnabled(flag);
        // b_bytes.setEnabled(flag);
        // b_query.setEnabled(flag);
        b_baidu.setEnabled(flag);
        //b_length.setEnabled(flag);
        b_continu.setEnabled(flag);
        b_koubei.setEnabled(flag);
        // b_runpaper.setEnabled(flag);
        // b_motor.setEnabled(flag);
        b_demo.setEnabled(flag);
        // b_wave.setEnabled(flag);
        // b_error.setEnabled(flag);
        //b_loop.setEnabled(flag);
    }

    /**
     * 消息处理
     */
    private HandlerUtils.IHandlerIntent iHandlerIntent = new HandlerUtils.IHandlerIntent() {
        @Override
        public void handlerIntent(Message msg) {
            switch (msg.what) {
                case MSG_TEST:
                    break;
                case MSG_IS_NORMAL:
                    if (getPrinterStatus() == PRINTER_NORMAL) {
                        loopPrint(loopPrintFlag);
                    }
                    break;
                case MSG_IS_BUSY:
                    Toast.makeText(IPosPrinterTestDemo.this, R.string.printer_is_working, Toast.LENGTH_SHORT).show();
                    break;
                case MSG_PAPER_LESS:
                    loopPrintFlag = DEFAULT_LOOP_PRINT;
                    Toast.makeText(IPosPrinterTestDemo.this, R.string.out_of_paper, Toast.LENGTH_SHORT).show();
                    break;
                case MSG_PAPER_EXISTS:
                    Toast.makeText(IPosPrinterTestDemo.this, R.string.exists_paper, Toast.LENGTH_SHORT).show();
                    break;
                case MSG_THP_HIGH_TEMP:
                    Toast.makeText(IPosPrinterTestDemo.this, R.string.printer_high_temp_alarm, Toast.LENGTH_SHORT).show();
                    break;
                case MSG_MOTOR_HIGH_TEMP:
                    loopPrintFlag = DEFAULT_LOOP_PRINT;
                    Toast.makeText(IPosPrinterTestDemo.this, R.string.motor_high_temp_alarm, Toast.LENGTH_SHORT).show();
                    handler.sendEmptyMessageDelayed(MSG_MOTOR_HIGH_TEMP_INIT_PRINTER, 180000);  //马达高温报警，等待3分钟后复位打印机
                    break;
                case MSG_MOTOR_HIGH_TEMP_INIT_PRINTER:
                    printerInit();
                    break;
                case MSG_CURRENT_TASK_PRINT_COMPLETE:
                    Toast.makeText(IPosPrinterTestDemo.this, R.string.printer_current_task_print_complete, Toast.LENGTH_SHORT).show();
                    break;
                default:
                    break;
            }
        }
    };

    private BroadcastReceiver IPosPrinterStatusListener = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action == null) {
                Log.d(TAG, "IPosPrinterStatusListener onReceive action = null");
                return;
            }
            Log.d(TAG, "IPosPrinterStatusListener action = " + action);
            if (action.equals(PRINTER_NORMAL_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_IS_NORMAL, 0);
            } else if (action.equals(PRINTER_PAPERLESS_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_PAPER_LESS, 0);
            } else if (action.equals(PRINTER_BUSY_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_IS_BUSY, 0);
            } else if (action.equals(PRINTER_PAPEREXISTS_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_PAPER_EXISTS, 0);
            } else if (action.equals(PRINTER_THP_HIGHTEMP_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_THP_HIGH_TEMP, 0);
            } else if (action.equals(PRINTER_THP_NORMALTEMP_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_THP_TEMP_NORMAL, 0);
            } else if (action.equals(PRINTER_MOTOR_HIGHTEMP_ACTION))  //此时当前任务会继续打印，完成当前任务后，请等待2分钟以上时间，继续下一个打印任务
            {
                handler.sendEmptyMessageDelayed(MSG_MOTOR_HIGH_TEMP, 0);
            } else if (action.equals(PRINTER_CURRENT_TASK_PRINT_COMPLETE_ACTION)) {
                handler.sendEmptyMessageDelayed(MSG_CURRENT_TASK_PRINT_COMPLETE, 0);
            } else if (action.equals(GET_CUST_PRINTAPP_PACKAGENAME_ACTION)) {
                String mPackageName = intent.getPackage();
                Log.d(TAG, "*******GET_CUST_PRINTAPP_PACKAGENAME_ACTION：" + action + "*****mPackageName:" + mPackageName);

            } else {
                handler.sendEmptyMessageDelayed(MSG_TEST, 0);
            }
        }
    };


    /**
     * 绑定服务实例
     */
    private ServiceConnection connectService = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mIPosPrinterService = IPosPrinterService.Stub.asInterface(service);
            setButtonEnable(true);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mIPosPrinterService = null;
        }
    };

    public static void writePrintDataToCacheFile(String printStr, byte[] printByteData) {
        String printDataDirPath = Environment.getExternalStorageDirectory()+File.separator+"PrintDataCache";
        String printDataFilePath1 = printDataDirPath +File.separator+ "printdata_1.txt";
        String printDataFilePath2 = printDataDirPath +File.separator+ "printdata_2.txt";
        Log.d(TAG, "printDataDirPath:" + printDataDirPath);

        File fileDir = new File(printDataDirPath);
        if (!fileDir.exists()) {
            fileDir.mkdirs();
        }


        if (fileDir.exists()) {
            Log.d(TAG, printDataDirPath + " is exists!!!!!");
        } else {
            Log.d(TAG, printDataDirPath + " is not exists!!!!!");
        }

        File printDataFile = new File(printDataFilePath1);
        if (printDataFile.exists() && printDataFile.isFile()) {
            if (printDataFile.length() > 5 * 1024 * 1024) {
                printDataFile = new File(printDataFilePath2);
                if (printDataFile.exists() && printDataFile.isFile()) {
                    if (printDataFile.length() > 5 * 1024 * 1024) {
                        return;
                    }
                } else {
                    try {
                        printDataFile.createNewFile();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        } else {
            printDataFile = new File(printDataFilePath2);
            if (printDataFile.exists() && printDataFile.isFile()) {
                if (printDataFile.length() > 5 * 1024 * 1024) {
                    printDataFile = new File(printDataFilePath1);
                }
            } else {
                printDataFile = new File(printDataFilePath1);
                try {
                    printDataFile.createNewFile();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        if ((printStr == null) && (printByteData == null)) {
            return;
        }

        FileOutputStream fileOut = null;
        if (printStr != null) {
            BufferedWriter outw = null;
            try {
                fileOut = new FileOutputStream(printDataFile, true);
                outw = new BufferedWriter(new OutputStreamWriter(fileOut));
                outw.write(printStr);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e1) {
                e1.printStackTrace();
            } finally {
                try {
                    if (outw != null) {
                        outw.close();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        if (printByteData != null) {
            BufferedOutputStream bufOut = null;
            try {
                fileOut = new FileOutputStream(printDataFile, true);
                bufOut = new BufferedOutputStream(fileOut);
                bufOut.write(printByteData);

            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e1) {
                e1.printStackTrace();
            } finally {
                try {
                    if (fileOut != null) {
                        fileOut.close();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }

                try {
                    if (bufOut != null) {
                        bufOut.close();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ipos_printer_test_demo);
        //设置屏幕一直亮着，不进入休眠状态
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        handler = new HandlerUtils.MyHandler(iHandlerIntent);
        innitView();
        callback = new IPosPrinterCallback.Stub() {

            @Override
            public void onRunResult(final boolean isSuccess) throws RemoteException {
                Log.i(TAG, "result:" + isSuccess + "\n");
            }

            @Override
            public void onReturnString(final String value) throws RemoteException {
                Log.i(TAG, "result:" + value + "\n");
            }
        };

        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(IPosPrinterTestDemo.this,new String[]{Manifest.permission.MOUNT_UNMOUNT_FILESYSTEMS, Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
            }
        }

        writePrintDataToCacheFile("*****************", null);
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        //询问用户权限
        if (permissions[0].equals(Manifest.permission.WRITE_EXTERNAL_STORAGE) && grantResults[0]
                == PackageManager.PERMISSION_GRANTED) {
            //用户同意
        } else {
            //用户不同意
        }
    }

    @Override
    protected void onResume() {
        Log.d(TAG, "activity onResume");
        super.onResume();
        //绑定服务
        Intent intent = new Intent();
        intent.setPackage("com.iposprinter.iposprinterservice");
        intent.setAction("com.iposprinter.iposprinterservice.IPosPrintService");
        //startService(intent);
        bindService(intent, connectService, Context.BIND_AUTO_CREATE);
        //注册打印机状态接收器
        IntentFilter printerStatusFilter = new IntentFilter();
        printerStatusFilter.addAction(PRINTER_NORMAL_ACTION);
        printerStatusFilter.addAction(PRINTER_PAPERLESS_ACTION);
        printerStatusFilter.addAction(PRINTER_PAPEREXISTS_ACTION);
        printerStatusFilter.addAction(PRINTER_THP_HIGHTEMP_ACTION);
        printerStatusFilter.addAction(PRINTER_THP_NORMALTEMP_ACTION);
        printerStatusFilter.addAction(PRINTER_MOTOR_HIGHTEMP_ACTION);
        printerStatusFilter.addAction(PRINTER_BUSY_ACTION);
        printerStatusFilter.addAction(GET_CUST_PRINTAPP_PACKAGENAME_ACTION);

        registerReceiver(IPosPrinterStatusListener, printerStatusFilter);
    }

    @Override
    protected void onPause() {
        Log.d(TAG, "activity onPause");
        super.onPause();
    }

    @Override
    protected void onStop() {
        Log.e(TAG, "activity onStop");
        super.onStop();// ATTENTION: This was auto-generated to implement the App Indexing API.
// See https://g.co/AppIndexing/AndroidStudio for more information.
        AppIndex.AppIndexApi.end(client, getIndexApiAction());
        loopPrintFlag = DEFAULT_LOOP_PRINT;
        unregisterReceiver(IPosPrinterStatusListener);
        unbindService(connectService);
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.disconnect();
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "activity onDestroy");
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }

    private void innitView() {
        b_barcode = (Button) findViewById(R.id.b_barcode);
        b_pic = (Button) findViewById(R.id.b_pic);
        b_qcode = (Button) findViewById(R.id.b_qcode);
        //b_self = (Button) findViewById(R.id.b_self);
        b_text = (Button) findViewById(R.id.b_text);
        b_table = (Button) findViewById(R.id.b_table);
        //b_init = (Button) findViewById(R.id.b_init);
        b_lines = (Button) findViewById(R.id.b_lines);
        b_test = (Button) findViewById(R.id.b_test);
        // b_runpaper = (Button) findViewById(R.id.b_runpaper);
        //b_length = (Button) findViewById(R.id.b_length);
        b_continu = (Button) findViewById(R.id.b_continu);
        // b_motor = (Button) findViewById(R.id.b_motor);
        // b_wave = (Button) findViewById(R.id.b_wave);
        b_koubei = (Button) findViewById(R.id.b_koubei);
        // b_error = (Button) findViewById(R.id.b_error);
        // b_loop = (Button) findViewById(R.id.b_loop);
        b_demo = (Button) findViewById(R.id.b_demo);

        findViewById(R.id.b_exit).setOnClickListener(this);
        findViewById(R.id.b_block).setOnClickListener(this);
        b_barcode.setOnClickListener(this);
        b_pic.setOnClickListener(this);
        b_qcode.setOnClickListener(this);
        // b_self.setOnClickListener(this);
        b_text.setOnClickListener(this);
        b_table.setOnClickListener(this);
        //b_init.setOnClickListener(this);
        b_lines.setOnClickListener(this);
        b_test.setOnClickListener(this);
        //b_runpaper.setOnClickListener(this);
        //b_length.setOnClickListener(this);
        b_continu.setOnClickListener(this);
        //b_motor.setOnClickListener(this);
        // b_wave.setOnClickListener(this);
        b_koubei.setOnClickListener(this);
        // b_error.setOnClickListener(this);
        // b_loop.setOnClickListener(this);
        b_demo.setOnClickListener(this);

        //b_bytes = (Button) findViewById(R.id.b_bytes);
        //b_query = (Button) findViewById(R.id.b_query);
        b_baidu = (Button) findViewById(R.id.b_baidu);
        b_meituan = (Button) findViewById(R.id.b_meituan);
        b_erlmo = (Button) findViewById(R.id.b_erlmo);
        //b_testall = (Button) findViewById(R.id.b_testall);


        //b_bytes.setOnClickListener(this);
        //b_query.setOnClickListener(this);
        b_baidu.setOnClickListener(this);
        b_meituan.setOnClickListener(this);
        b_erlmo.setOnClickListener(this);
        // b_testall.setOnClickListener(this);

        setButtonEnable(false);
        info = (TextView) findViewById(R.id.info);
        info.setText(VERSION);
    }

    @Override
    public void onClick(View v) {
        if (ButtonDelayUtils.isFastDoubleClick()) {
            return;
        }
        switch (v.getId()) {
            //打印随机黑点
            /*
            case R.id.b_length:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printRandomDot(500);
                break;
             */
            //打印长黑块
            case R.id.b_block:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printBlackBlock(500);
                break;
            //并发多线程混乱打印测试
            /*
            case R.id.b_testall:
                if (getPrinterStatus() == PRINTER_NORMAL)
                {
                    multiThreadLoopPrint();
                    loopPrintFlag = MULTI_THREAD_LOOP_PRINT;
                }
                break;
              */
            //饿了么外卖
            case R.id.b_erlmo:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printErlmoBill();
                break;
            //口碑外卖
            case R.id.b_koubei:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printKoubeiBill();
                break;
            //美团小票
            case R.id.b_meituan:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printMeiTuanBill();
                break;
            //百度小票
            case R.id.b_baidu:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printBaiduBill();
                break;
            //查询开机以来打印长度
            /*
            case R.id.b_query:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    queryPrintLength();
                break;

            //打印自检页
            case R.id.b_self:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printSelf();
                break;
            */
            //打印多个空白行
            case R.id.b_lines:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printLineWrap(3, 24);
                break;
            //打印机初始化
            /*
            case R.id.b_init:
                if (getPrinterStatus() == PRINTER_NORMAL)
                     printerInit();
                break;
              */
            //打印文字
            case R.id.b_text:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printText();
                break;
            //打印表格
            case R.id.b_table:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printTable();
                break;
            //打印图片
            case R.id.b_pic:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printBitmap();
                break;
            //打印一维码
            case R.id.b_barcode:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printBarcode();
                break;
            //打印二维码
            case R.id.b_qcode:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printQRCode();
                break;
            //综合测试
            case R.id.b_test:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    fullTest();
                break;
            //用于演示模式
            case R.id.b_demo:
                if (getPrinterStatus() == PRINTER_NORMAL) {
                    loopPrintFlag = DEMO_LOOP_PRINT;
                    demoLoopPrint();
                }
                break;
            //退出应用
            case R.id.b_exit:
                loopPrintFlag = DEFAULT_LOOP_PRINT;
                finish();
                break;
            //十六进制输入
            /*
            case R.id.b_bytes:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    inputBytes(1);
                break;
                */
            case R.id.b_continu:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    continuPrint();
                break;
            /*
            case R.id.b_error:
                if (getPrinterStatus() == PRINTER_NORMAL)
                {
                    loopPrintFlag = PRINT_DRIVER_ERROR_TEST;
                    printDriverTest();
                }
                break;
            case R.id.b_loop:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    inputBytes(2);
                break;
            case R.id.b_wave:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    wavePrintTest();
                break;
            case R.id.b_runpaper:
                if (getPrinterStatus() == PRINTER_NORMAL)
                    printerRunPaper(500);
                break;
            case R.id.b_motor:
                    printerInit();
                break;
            */
            default:
                break;
        }
    }

    /**
     * 获取打印机状态
     */
    public int getPrinterStatus() {

        Log.i(TAG, "***** printerStatus" + printerStatus);
        try {
            printerStatus = mIPosPrinterService.getPrinterStatus();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        Log.i(TAG, "#### printerStatus" + printerStatus);
        return printerStatus;
    }

    /**
     * 打印机初始化
     */
    public void printerInit() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printerInit(callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印机自检
     */
    public void printSelf() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {

                    mIPosPrinterService.printerInit(callback);

                    mIPosPrinterService.printSpecifiedTypeText("   打印机自检\n", "ST", 48, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printRawData(BytesUtil.BlackBlockData(300), callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 10, 1, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printSpecifiedTypeText("   打印机正常\n", "ST", 48, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);
                    mIPosPrinterService.printSpecifiedTypeText("        欢迎使用\n", "ST", 32, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);

                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 获取打印长度
     */
    public void queryPrintLength() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printSpecifiedTypeText("获取打印长度\n暂未实现\n\n----------end-----------\n\n", "ST", 32, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印机走纸
     */
    public void printerRunPaper(final int lines) {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printerFeedLines(lines, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印空白行
     */
    public void printLineWrap(final int lines, final int height) {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printBlankLines(lines, height, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印随机黑点
     */
    public void printRandomDot(final int lines) {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printRawData(BytesUtil.RandomDotData(lines), callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印大黑块
     */
    public void printBlackBlock(final int height) {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printRawData(BytesUtil.BlackBlockData(height), callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印文字
     */
    public void printText() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                Bitmap mBitmap = BitmapFactory.decodeResource(getResources(), R.mipmap.test);
                try {
                    mIPosPrinterService.printSpecifiedTypeText("    智能POS机\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("    智能POS机数据终端\n", "ST", 32, callback);
                    mIPosPrinterService.printBlankLines(1, 8, callback);
                    mIPosPrinterService.printSpecifiedTypeText("      欢迎使智能POS机数据终端\n", "ST", 24, callback);
                    mIPosPrinterService.printBlankLines(1, 8, callback);
                    mIPosPrinterService.printSpecifiedTypeText("智能POS 数据终端 智能POS\n", "ST", 32, callback);
                    mIPosPrinterService.printBlankLines(1, 8, callback);
                    mIPosPrinterService.printSpecifiedTypeText("#POS POS ipos POS POS POS POS ipos POS POS ipos#\n", "ST", 16, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);
                    mIPosPrinterService.printBitmap(1, 12, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);
                    mIPosPrinterService.PrintSpecFormatText("开启打印测试\n", "ST", 32, 1, callback);
                    mIPosPrinterService.printSpecifiedTypeText("********************************", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("这是一行16号字体\n", "ST", 16, callback);
                    mIPosPrinterService.printSpecifiedTypeText("这是一行24号字体\n", "ST", 24, callback);
                    mIPosPrinterService.PrintSpecFormatText("这是一行24号字体\n", "ST", 24, 2, callback);
                    mIPosPrinterService.printSpecifiedTypeText("这是一行32号字体\n", "ST", 32, callback);
                    mIPosPrinterService.PrintSpecFormatText("这是一行32号字体\n", "ST", 32, 2, callback);
                    mIPosPrinterService.printSpecifiedTypeText("这是一行48号字体\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n", "ST", 16, callback);
                    mIPosPrinterService.printSpecifiedTypeText("ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("κρχκμνκλρκνκνμρτυφ\n", "ST", 24, callback);
                    mIPosPrinterService.setPrinterPrintAlignment(0, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 10, 1, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);
                    for (int i = 0; i < 12; i++) {
                        mIPosPrinterService.printRawData(BytesUtil.initLine1(384, i), callback);
                    }
                    mIPosPrinterService.PrintSpecFormatText("打印测试完成\n", "ST", 32, 1, callback);
                    mIPosPrinterService.printSpecifiedTypeText("**********END***********\n\n", "ST", 32, callback);
                    bitmapRecycle(mBitmap);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印表格
     */
    public void printTable() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.setPrinterPrintAlignment(0, callback);
                    mIPosPrinterService.setPrinterPrintFontSize(24, callback);
                    String[] text = new String[4];
                    int[] width = new int[]{8, 6, 6, 7};
                    int[] align = new int[]{0, 2, 2, 2}; // 左齐,右齐,右齐,右齐
                    text[0] = "名称";
                    text[1] = "数量";
                    text[2] = "单价";
                    text[3] = "金额";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "草莓酸奶A布甸";
                    text[1] = "4";
                    text[2] = "12.00";
                    text[3] = "48.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包B";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果布甸香橙软桃蛋糕"; // 文字超长,换行
                    text[1] = "100";
                    text[2] = "16.00";
                    text[3] = "1600.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.setPrinterPrintFontSize(24, callback);
                    text = new String[3];
                    width = new int[]{8, 6, 7};
                    align = new int[]{0, 2, 2};
                    text[0] = "菜品";
                    text[1] = "数量";
                    text[2] = "金额";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "草莓酸奶布甸";
                    text[1] = "4";
                    text[2] = "48.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包B";
                    text[1] = "10";
                    text[2] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果布甸香橙软桃蛋糕"; // 文字超长,换行
                    text[1] = "100";
                    text[2] = "1600.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包";
                    text[1] = "10";
                    text[2] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(2, callback);
                    mIPosPrinterService.setPrinterPrintFontSize(16, callback);
                    text = new String[4];
                    width = new int[]{10, 6, 6, 8};
                    align = new int[]{0, 2, 2, 2}; // 左齐,右齐,右齐,右齐
                    text[0] = "名称";
                    text[1] = "数量";
                    text[2] = "单价";
                    text[3] = "金额";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "草莓酸奶A布甸";
                    text[1] = "4";
                    text[2] = "12.00";
                    text[3] = "48.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包B";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果布甸香橙软桃蛋糕"; // 文字超长,换行
                    text[1] = "100";
                    text[2] = "16.00";
                    text[3] = "1600.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 8, callback);

                    mIPosPrinterService.printerPerformPrint(160, callback);

                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印图片
     */
    public void printBitmap() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                Bitmap mBitmap = BitmapFactory.decodeResource(getResources(), R.mipmap.test_p);
                try {
                    mIPosPrinterService.printBitmap(0, 4, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printBitmap(1, 6, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printBitmap(2, 8, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printBitmap(2, 10, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printBitmap(1, 12, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printBitmap(0, 14, mBitmap, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印一维码
     */
    public void printBarcode() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.setPrinterPrintAlignment(0, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 2, 5, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 3, 6, 1, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(2, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 4, 7, 2, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(2, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 5, 8, 3, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 3, 7, 3, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 3, 6, 1, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printBarCode("2017072618", 8, 3, 4, 2, callback);
                    mIPosPrinterService.printBlankLines(1, 25, callback);

                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印二维码
     */
    public void printQRCode() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.setPrinterPrintAlignment(0, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 2, 1, callback);
                    mIPosPrinterService.printBlankLines(1, 15, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 3, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 15, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(2, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 4, 2, callback);
                    mIPosPrinterService.printBlankLines(1, 15, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(0, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 5, 3, callback);
                    mIPosPrinterService.printBlankLines(1, 15, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 6, 2, callback);
                    mIPosPrinterService.printBlankLines(1, 15, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(2, callback);
                    mIPosPrinterService.printQRCode("http://www.baidu.com\n", 7, 1, callback);
                    mIPosPrinterService.printBlankLines(1, 15, callback);

                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印饿了么小票
     */
    public void printErlmoBill() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printSpecifiedTypeText(Elemo, "ST", 32, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打百度小票
     */
    public void printBaiduBill() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                try {
                    mIPosPrinterService.printSpecifiedTypeText(Baidu, "ST", 32, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 口碑外卖
     */
    public void printKoubeiBill() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {

            @Override
            public void run() {
                try {
                    mIPosPrinterService.printSpecifiedTypeText("   #4口碑外卖\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("         " + "冯记黄焖鸡米饭\n********************************\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("17:20 尽快送达\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("18610858337韦小宝创智天地广场7号楼(605室)\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("下单: 16:35\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("********************************\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("菜品          数量   单价   " +
                            "金额\n--------------------------------\n黄焖五花肉 (大) (不辣)\n" +
                            "               1      25      25\n黄焖五花肉 (小) (不辣)\n               1      " +
                            "25      25黄焖五花肉 (小) (微辣)\n               1      25      25\n--------------------------------\n配送费" +
                            "  " +
                            "               " +
                            "        2\n--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("            实付金额: 27\n\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("    口碑外卖\n\n\n", "ST", 48, callback);

                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 美团小票
     */
    public void printMeiTuanBill() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {

            @Override
            public void run() {
                try {
                    mIPosPrinterService.printSpecifiedTypeText("  #1  美团测试\n\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("      粤香港式烧腊(第1联)\n\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("------------------------\n\n*********预订单*********\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("  期望送达时间:[18:00]\n\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n下单时间: " + "01-01 12:00", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("备注: 别太辣\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("菜品          数量   小计" + "金额\n--------------------------------\n\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("红烧肉          X1    12\n红烧肉1         X1   " + " 12\n红烧肉2         X1    12\n\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("配送费                         5\n餐盒费        " +
                            " " +
                            " " +
                            "               1\n[超时赔付] - 详见订单\n可口可乐: x1", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("合计                18元\n\n", "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("张* 18312345678\n地址信息\n", "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText("--------------------------------\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("  #1  美团测试\n\n\n", "ST", 48, callback);

                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 打印大数据
     * numK: 打印数据的大小，以4k为单位，最大127个4k，既十六进制0x7f
     * data: 打印内容
     */
    public void bigDataPrintTest(final int numK, final byte data) {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                int num4K = 1024 * 4;
                int length = numK > 127 ? num4K * 127 : num4K * numK;
                byte[] dataBytes = new byte[length];
                for (int i = 0; i < length; i++) {
                    dataBytes[i] = data;
                }
                try {
                    mIPosPrinterService.printRawData(dataBytes, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 综合打印测试
     */
    public void fullTest() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                Bitmap bmp;
                try {
                    mIPosPrinterService.printRawData(BytesUtil.initBlackBlock(384), callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    mIPosPrinterService.printRawData(BytesUtil.initBlackBlock(48, 384), callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    mIPosPrinterService.printRawData(BytesUtil.initGrayBlock(48, 384), callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    mIPosPrinterService.setPrinterPrintAlignment(0, callback);
                    mIPosPrinterService.setPrinterPrintFontSize(24, callback);
                    String[] text = new String[4];
                    int[] width = new int[]{10, 6, 6, 8};
                    int[] align = new int[]{0, 2, 2, 2}; // 左齐,右齐,右齐,右齐
                    text[0] = "名称";
                    text[1] = "数量";
                    text[2] = "单价";
                    text[3] = "金额";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "草莓酸奶A布甸";
                    text[1] = "4";
                    text[2] = "12.00";
                    text[3] = "48.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包B";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果布甸香橙软桃蛋糕"; // 文字超长,换行
                    text[1] = "100";
                    text[2] = "16.00";
                    text[3] = "1600.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(1, callback);
                    mIPosPrinterService.setPrinterPrintFontSize(24, callback);
                    text = new String[3];
                    width = new int[]{10, 6, 8};
                    align = new int[]{0, 2, 2};
                    text[0] = "菜品";
                    text[1] = "数量";
                    text[2] = "金额";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "草莓酸奶布甸";
                    text[1] = "4";
                    text[2] = "48.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包B";
                    text[1] = "10";
                    text[2] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果布甸香橙软桃蛋糕"; // 文字超长,换行
                    text[1] = "100";
                    text[2] = "1600.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包";
                    text[1] = "10";
                    text[2] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 16, callback);

                    mIPosPrinterService.setPrinterPrintAlignment(2, callback);
                    mIPosPrinterService.setPrinterPrintFontSize(16, callback);
                    text = new String[4];
                    width = new int[]{10, 6, 6, 8};
                    align = new int[]{0, 2, 2, 2}; // 左齐,右齐,右齐,右齐
                    text[0] = "名称";
                    text[1] = "数量";
                    text[2] = "单价";
                    text[3] = "金额";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "草莓酸奶A布甸";
                    text[1] = "4";
                    text[2] = "12.00";
                    text[3] = "48.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包B";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果布甸香橙软桃蛋糕"; // 文字超长,换行
                    text[1] = "100";
                    text[2] = "16.00";
                    text[3] = "1600.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 1, callback);
                    text[0] = "酸奶水果夹心面包";
                    text[1] = "10";
                    text[2] = "4.00";
                    text[3] = "40.00";
                    mIPosPrinterService.printColumnsText(text, width, align, 0, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    bmp = BitmapFactory.decodeResource(getResources(), R.mipmap.test_p);
                    mIPosPrinterService.printBitmap(0, 12, bmp, callback);
                    mIPosPrinterService.printBitmap(1, 6, bmp, callback);
                    mIPosPrinterService.printBitmap(2, 16, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printSpecifiedTypeText("智能POS\n" +
                            "智能POS智能POS\n" +
                            "智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS智能POS智能POS智能\n" +
                            "智能POS智能POS智能POS智能POS智能POS智能POS智能\n" +
                            "智能POS智能POS智能POS智能POS智能POS智能POS智能\n" +
                            "智能POS智能POS智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS\n" +
                            "智能POS智能POS\n" +
                            "智能POS\n", "ST", 16, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    mIPosPrinterService.printSpecifiedTypeText("智能POS\n" +
                            "智能POS智能POS\n" +
                            "智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS智能POS智能\n" +
                            "智能POS智能POS智能POS智能POS\n" +
                            "智能POS智能POS智能POS\n" +
                            "智能POS智能POS\n" +
                            "智能POS\n", "ST", 24, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    mIPosPrinterService.printSpecifiedTypeText("手\n" +
                            "手手\n" +
                            "手手手\n" +
                            "手手手手\n" +
                            "手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手手手\n" +
                            "手手手手手手手手\n" +
                            "手手手手手手手手手\n" +
                            "手手手手手手手手手手\n" +
                            "手手手手手手手手手手手\n" +
                            "手手手手手手手手手手手手" +
                            "手手手手手手手手手手手\n" +
                            "手手手手手手手手手手\n" +
                            "手手手手手手手手手\n" +
                            "手手手手手手手手\n" +
                            "手手手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手\n" +
                            "手手手手\n" +
                            "手手手\n" +
                            "手手\n" +
                            "手\n", "ST", 32, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    mIPosPrinterService.printSpecifiedTypeText("手\n" +
                            "手手\n" +
                            "手手手\n" +
                            "手手手手\n" +
                            "手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手手手\n" +
                            "手手手手手手手手" +
                            "手手手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手\n" +
                            "手手手手\n" +
                            "手手手\n" +
                            "手手\n" +
                            "手\n", "ST", 48, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    int k = 8;
                    for (int i = 0; i < 48; i++) {
                        bmp = BytesUtil.getLineBitmapFromData(12, k);
                        k += 8;
                        if (null != bmp) {
                            mIPosPrinterService.printBitmap(1, 11, bmp, callback);
                        }
                    }
                    mIPosPrinterService.printBlankLines(1, 10, callback);
                    /*加快bitmap回收，减少内存占用*/
                    bitmapRecycle(bmp);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 手动输入指令打印
     */
    public void inputBytes(final int flag) {
        final EditText inputServer = new EditText(this);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Server").setIcon(android.R.drawable.ic_dialog_info).setView(inputServer).setNegativeButton("Cancel", null);
        builder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                byte[] inputCommand;
                inputCommand = BytesUtil.getBytesFromHexString(inputServer.getText().toString());
                System.out.println(BytesUtil.getHexStringFromBytes(inputCommand));
                if (null != inputCommand) {
                    switch (flag) {
                        //手动输入，第一个字节输入打印内容大小，以4k为单位，第二个字节输入打印内容
                        case 1:
                            bigDataPrintTest((int) inputCommand[0], inputCommand[1]);
                            break;
                        //循环打印
                        case 2:
                            loopPrintFlag = INPUT_CONTENT_LOOP_PRINT;
                            loopContent = inputCommand[0];
                            bigDataPrintTest(127, loopContent);
                            break;
                    }


                }
            }
        });
        builder.show();
    }

    /**
     * 连续打印测试
     */
    public void continuPrint() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.mipmap.test);
                try {
                    mIPosPrinterService.printSpecifiedTypeText(customCHR, "ST", 16, callback);
                    mIPosPrinterService.printSpecifiedTypeText(Text, "ST", 16, callback);
                    mIPosPrinterService.printSpecifiedTypeText(customCHR, "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText(Text, "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText(customCHR, "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText(Text, "ST", 32, callback);
                    mIPosPrinterService.printSpecifiedTypeText(customCHR, "ST", 48, callback);
                    mIPosPrinterService.printSpecifiedTypeText(customCHZ1, "ST", 48, callback);
                    mIPosPrinterService.printBlankLines(1, 10, callback);

                    mIPosPrinterService.printBitmap(0, 4, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(0, 5, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(0, 6, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(0, 7, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(0, 8, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);

                    mIPosPrinterService.printBitmap(1, 9, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(1, 10, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(1, 11, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(1, 12, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(1, 13, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);

                    mIPosPrinterService.printBitmap(2, 12, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(3, 11, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(4, 10, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(5, 9, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    mIPosPrinterService.printBitmap(6, 8, bmp, callback);
                    mIPosPrinterService.printBlankLines(1, 20, callback);
                    /*加快bitmap回收，减少内存占用*/
                    bitmapRecycle(bmp);

                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 波形测试
     */
    public void wavePrintTest() {
        ThreadPoolManager.getInstance().executeTask(new Runnable() {
            @Override
            public void run() {
                int length = 100;
                byte[] data = new byte[48 * length * 5];
                for (int i = 0; i < length; i++) {
                    for (int x = 0; x < 5; x++) {
                        for (int j = 0; j < 48; j++) {
                            if (i % 2 != 0) {
                                data[48 * (5 * i + x) + j] = (byte) 0xff;
                            } else {
                                data[48 * (5 * i + x) + j] = (byte) 0x01;
                            }
                        }
                    }
                }
                try {
                    mIPosPrinterService.printRawData(data, callback);
                    mIPosPrinterService.printSpecifiedTypeText("\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手手手手手\n" +
                            "手                                                   " +
                            "手手   手手   手手  手手\n" +
                            "手\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手手手\n" +
                            "手手\n" +
                            "手\n" +
                            "                                     " +
                            "                                     " +
                            "手手手手手手手手手手手手手手手手手手\n" +
                            "手手手\n" +
                            "手\n" +
                            "手\n" +
                            "手手手手手手手手\n" +
                            "\n" +
                            "手手手手手手手手手手手手手手\n" +
                            "手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手手\n" +
                            "手\n", "ST", 16, callback);
                    mIPosPrinterService.printSpecifiedTypeText("\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手手手手手\n" +
                            "手                                                   " +
                            "手手   手手   手手  手手\n" +
                            "手\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手手手\n" +
                            "手手\n" +
                            "手\n" +
                            "                                     " +
                            "                                     " +
                            "手手手手手手手手手手手手手\n" +
                            "手手手\n" +
                            "手\n" +
                            "手\n" +
                            "手手手手手手手手\n" +
                            "\n" +
                            "手手手手手手手手手手手手手手\n" +
                            "手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手手\n" +
                            "手\n", "ST", 24, callback);
                    mIPosPrinterService.printSpecifiedTypeText("\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手手手手手\n" +
                            "手                                                   " +
                            "手手   手手   手手  手手\n" +
                            "手\n" +
                            "手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手手\n" +
                            "手手手\n" +
                            "手手\n" +
                            "手\n" +
                            "                                     " +
                            "                                     " +
                            "手手手手手手手手手手手手手\n" +
                            "手手手\n" +
                            "手\n" +
                            "手\n" +
                            "手手手手手手手手\n" +
                            "\n" +
                            "手手手手手手手手手手手手手手\n" +
                            "手手手手手\n" +
                            "手手手手手手\n" +
                            "手手手手手手\n" +
                            "手\n", "ST", 32, callback);
                    mIPosPrinterService.printerPerformPrint(160, callback);
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 循环打印
     */
    public void loopPrint(int flag) {
        switch (flag) {
            case MULTI_THREAD_LOOP_PRINT:
                multiThreadLoopPrint();
                break;
            case DEMO_LOOP_PRINT:
                demoLoopPrint();
                break;
            case INPUT_CONTENT_LOOP_PRINT:
                bigDataPrintTest(127, loopContent);
                break;
            case PRINT_DRIVER_ERROR_TEST:
                printDriverTest();
                break;
            default:
                break;
        }
    }

    /**
     * 并发多线程打印
     */
    public void multiThreadLoopPrint() {
        Log.e(TAG, "发起打印任务 --> ");
        switch (random.nextInt(12)) {
            case 0:
                printText();
                break;
            case 1:
                printBarcode();
                break;
            case 2:
                fullTest();
                break;
            case 3:
                printQRCode();
                break;
            case 4:
                printBitmap();
                break;
            case 5:
                printTable();
                break;
            case 6:
                printBaiduBill();
                break;
            case 7:
                printKoubeiBill();
                break;
            case 8:
                printMeiTuanBill();
                break;
            case 9:
                printErlmoBill();
                break;
            case 10:
                printSelf();
                break;
            case 11:
                continuPrint();
                break;
            default:
                break;
        }
    }

    public void demoLoopPrint() {
        Log.e(TAG, "发起演示模式 --> ");
        switch (random.nextInt(7)) {
            case 0:
                printKoubeiBill();
                break;
            case 1:
                printBarcode();
                break;
            case 2:
                printBaiduBill();
                break;
            case 3:
                printBitmap();
                break;
            case 4:
                printErlmoBill();
                break;
            case 5:
                printQRCode();
                break;
            case 6:
                printMeiTuanBill();
                break;
            default:
                break;
        }
    }

    /**
     * 每次下发内容以64k为单位递增，最大512k
     */
    public void printDriverTest() {
        if (printDriverTestCount >= 8) {
            loopPrintFlag = DEFAULT_LOOP_PRINT;
            printDriverTestCount = 0;
        } else {
            printDriverTestCount++;
            bigDataPrintTest(printDriverTestCount * 16, (byte) 0x11);
        }
    }

    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    public Action getIndexApiAction() {
        Thing object = new Thing.Builder()
                .setName("IPosPrinterTestDemo Page") // TODO: Define a title for the content shown.
                // TODO: Make sure this auto-generated URL is correct.
                .setUrl(Uri.parse("http://[ENTER-YOUR-URL-HERE]"))
                .build();
        return new Action.Builder(Action.TYPE_VIEW)
                .setObject(object)
                .setActionStatus(Action.STATUS_TYPE_COMPLETED)
                .build();
    }

    @Override
    public void onStart() {
        super.onStart();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.connect();
        AppIndex.AppIndexApi.start(client, getIndexApiAction());
    }
}
