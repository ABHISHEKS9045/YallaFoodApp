package com.iposprinter.printertestdemo.Utils;

/**
 * Created by Administrator on 2017/7/25.
 */
import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import java.util.Random;
import java.io.ByteArrayOutputStream;


public class BytesUtil {
    private static final String TAG             = "BytesUtil";
    private static final int    MATRIX_DATA_ROW = 384;
    private static final int    BYTE_BIT        = 8;
    private static final int    BYTE_PER_LINE   = 48;
    // =============================================================================================
    // Fields
    // =============================================================================================
    private static Random random = new Random();

    // =============================================================================================
    // Methods
    // =============================================================================================

    /**
     * 随机生成黑点打印数据
     */
    public static byte[] RandomDotData(int lines)
    {
        byte[] printData = new byte[lines * BYTE_PER_LINE];
        for (int i = 0; i < lines; i++)
        {
            byte[] lineData = new byte[BYTE_PER_LINE];
            int randData = random.nextInt(BYTE_PER_LINE);
            lineData[randData] = 0x01;
            System.arraycopy(lineData, 0, printData, i * 48, BYTE_PER_LINE);
        }

        return printData;
    }
    /**
     * 生成间断性黑块数据
     *
     * @param w : 打印纸宽度, 单位点
     * @return
     */
    public static byte[] initBlackBlock(int w)
    {
        int ww = w / 8;
        int n = ww  / 12;
        int hh = n * 24;
        byte[] data = new byte[hh * ww ];


        int k = 0;
        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < 24; j++)
            {
                for (int m = 0; m < ww; m++)
                {
                    if (m / 12 == i)
                    {
                        data[k++] = (byte) 0xFF;
                    }
                    else
                    {
                        data[k++] = 0;
                    }
                }
            }
        }

        return data;
    }

    /**
     * 生成一大块黑块数据
     *
     * @param h : 黑块高度, 单位点
     * @param w : 黑块宽度, 单位点, 8的倍数
     * @return
     */
    public static byte[] initBlackBlock(int h, int w)
    {
        int hh = h;
        int ww = w  / 8 ;
        byte[] data = new byte[hh * ww ];

        int k = 0;
        for (int i = 0; i < hh; i++)
        {
            for (int j = 0; j < ww; j++)
            {
                data[k++] = (byte) 0xFF;
            }
        }

        return data;
    }

    /**
     * 生成黑块数据
     */
    public static byte[] BlackBlockData(int lines)
    {
        byte[] printData = new byte[lines * BYTE_PER_LINE];
        for (int i = 0; i < lines * BYTE_PER_LINE; i++)
        {
            printData[i] = (byte) 0xff;
        }
        return printData;
    }

    /**
     * 生成灰块数据
     *
     * @param h : 灰块高度, 单位点
     * @param w : 灰块宽度, 单位点, 8的倍数
     * @return
     */
    public static byte[] initGrayBlock(int h, int w)
    {
        int hh = h;
        int ww = w/ 8 ;
        byte[] data = new byte[hh * ww ];

        int k = 0;
        byte m = (byte) 0xAA;
        for (int i = 0; i < hh; i++)
        {
            m = (byte) ~m;
            for (int j = 0; j < ww; j++)
            {
                data[k++] = m;
            }
        }

        return data;
    }

    protected static Bitmap getBitmapFromData(int[] pixels, int width, int height)
    {
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
        return bitmap;
    }

    public static Bitmap getLineBitmapFromData(int size, int width)
    {
        int[] pixels = createLineData(size, width);
        return getBitmapFromData(pixels, width, size + 6);
    }

    public static String getHexStringFromBytes(byte[] data)
    {
        if (data == null || data.length <= 0)
        {
            return null;
        }
        String hexString = "0123456789ABCDEF";
        int size = data.length * 2;
        StringBuilder sb = new StringBuilder(size);
        for (int i = 0; i < data.length; i++)
        {
            sb.append(hexString.charAt((data[i] & 0xF0) >> 4));
            sb.append(hexString.charAt((data[i] & 0x0F) >> 0));
        }
        return sb.toString();
    }

    /**
     * 单字符转字节
     *
     * @param c
     * @return
     */
    private static byte charToByte(char c)
    {
        return (byte) "0123456789ABCDEF".indexOf(c);
    }

    /**
     * 16进制字符串转字节数组
     *
     * @param hexstring
     * @return
     */
    @SuppressLint("DefaultLocale")
    public static byte[] getBytesFromHexString(String hexstring)
    {
        if (hexstring == null || hexstring.equals(""))
        {
            return null;
        }
        hexstring = hexstring.replace(" ", "");
        hexstring = hexstring.toUpperCase();
        int size = hexstring.length() / 2;
        char[] hexarray = hexstring.toCharArray();
        byte[] rv = new byte[size];
        for (int i = 0; i < size; i++)
        {
            int pos = i * 2;
            rv[i] = (byte) (charToByte(hexarray[pos]) << 4 | charToByte(hexarray[pos + 1]));
        }
        return rv;
    }

    protected static int[] createLineData(int size, int width)
    {
        int[] pixels = new int[width * (size + 6)];
        int k = 0;
        for (int j = 0; j < 3; j++)
        {
            for (int i = 0; i < width; i++)
            {
                pixels[k++] = 0xffffffff;
            }
        }

        for (int j = 0; j < size; j++)
        {
            for (int i = 0; i < width; i++)
            {
                pixels[k++] = 0xff000000;
            }
        }

        for (int j = 0; j < 3; j++)
        {
            for (int i = 0; i < width; i++)
            {
                pixels[k++] = 0xffffffff;
            }
        }
        return pixels;
    }

    public static byte[] initLine1(int w, int type)
    {
        byte[][] kk = new byte[][]{{0x00, 0x00, 0x7c, 0x7c, 0x7c, 0x00, 0x00}, {0x00, 0x00, (byte) 0xff, (byte) 0xff, (byte) 0xff, 0x00, 0x00}, {0x00, 0x44, 0x44, (byte) 0xff, 0x44, 0x44, 0x00}, {0x00, 0x22, 0x55, (byte) 0x88, 0x55, 0x22, 0x00}, {0x08, 0x08, 0x1c, 0x7f, 0x1c, 0x08, 0x08}, {0x08, 0x14, 0x22, 0x41, 0x22, 0x14, 0x08}, {0x08, 0x14, 0x2a, 0x55, 0x2a, 0x14, 0x08}, {0x08, 0x1c, 0x3e, 0x7f, 0x3e, 0x1c, 0x08}, {0x49, 0x22, 0x14, 0x49, 0x14, 0x22, 0x49}, {0x63, 0x77, 0x3e, 0x1c, 0x3e, 0x77, 0x63}, {0x70, 0x20, (byte) 0xaf, (byte) 0xaa, (byte) 0xfa, 0x02, 0x07}, {(byte) 0xef, 0x28, (byte) 0xee, (byte) 0xaa, (byte) 0xee, (byte) 0x82, (byte) 0xfe},};

        int ww = w / 8;

        byte[] data = new byte[13 * ww ];

        int k = 0;
        for (int i = 0; i < 3 * ww; i++)
        {
            data[k++] = 0;
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][0];
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][1];
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][2];
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][3];
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][4];
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][5];
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = kk[type][6];
        }
        for (int i = 0; i < 3 * ww; i++)
        {
            data[k++] = 0;
        }
        return data;
    }

    public static byte[] initLine2(int w)
    {
        int ww = (w + 7) / 8;

        byte[] data = new byte[12 * ww + 8];

        data[0] = 0x1D;
        data[1] = 0x76;
        data[2] = 0x30;
        data[3] = 0x00;

        data[4] = (byte) ww;//xL
        data[5] = (byte) (ww >> 8);//xH
        data[6] = 12;  //高度13
        data[7] = 0;

        int k = 8;
        for (int i = 0; i < 5 * ww; i++)
        {
            data[k++] = 0;
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = 0x7f;
        }
        for (int i = 0; i < ww; i++)
        {
            data[k++] = 0x7f;
        }
        for (int i = 0; i < 5 * ww; i++)
        {
            data[k++] = 0;
        }
        return data;
    }

    /**
     * 将byte转化为16进制
     */
    public static String byte2hex(byte[] buffer)
    {
        String h = "";

        for (byte aBuffer : buffer)
        {
            String temp = Integer.toHexString(aBuffer & 0xFF);
            if (temp.length() == 1)
            {
                temp = "0" + temp;
            }
            h = h + " " + temp;
        }
        return h;
    }
}
