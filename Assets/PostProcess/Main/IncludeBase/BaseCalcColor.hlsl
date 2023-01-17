float3 rgb2hsv(float3 rgb)
{
    float3 hsv;

    // RGBの三つの値で最大のもの
    float maxValue = max(rgb.r, max(rgb.g, rgb.b));
    // RGBの三つの値で最小のもの
    float minValue = min(rgb.r, min(rgb.g, rgb.b));
    // 最大値と最小値の差
    float delta = maxValue - minValue;

    hsv.z = maxValue;

    if (maxValue != 0.0)
    {
        hsv.y = delta / maxValue;
    }
    else
    {
        hsv.y = 0.0;
    }

    if (hsv.y > 0.0)
    {
        if (rgb.r == maxValue)
        {
            hsv.x = (rgb.g - rgb.b) / delta;
        }
        else if (rgb.g == maxValue)
        {
            hsv.x = 2 + (rgb.b - rgb.r) / delta;
        }
        else
        {
            hsv.x = 4 + (rgb.r - rgb.g) / delta;
        }
        hsv.x /= 6.0;
        if (hsv.x < 0)
        {
            hsv.x += 1.0;
        }
    }

    return hsv;
}

float3 hsv2rgb(float3 hsv)
{
    float3 rgb;

    if (hsv.y == 0)
    {
        rgb.r = rgb.g = rgb.b = hsv.z;
    }
    else
    {
        hsv.x *= 6.0;
        float i = floor(hsv.x);
        float f = hsv.x - i;
        float aa = hsv.z * (1 - hsv.y);
        float bb = hsv.z * (1 - (hsv.y * f));
        float cc = hsv.z * (1 - (hsv.y * (1 - f)));
        if (i < 1)
        {
            rgb.r = hsv.z;
            rgb.g = cc;
            rgb.b = aa;
        }
        else if (i < 2)
        {
            rgb.r = bb;
            rgb.g = hsv.z;
            rgb.b = aa;
        }
        else if (i < 3)
        {
            rgb.r = aa;
            rgb.g = hsv.z;
            rgb.b = cc;
        }
        else if (i < 4)
        {
            rgb.r = aa;
            rgb.g = bb;
            rgb.b = hsv.z;
        }
        else if (i < 5)
        {
            rgb.r = cc;
            rgb.g = aa;
            rgb.b = hsv.z;
        }
        else
        {
            rgb.r = hsv.z;
            rgb.g = aa;
            rgb.b = bb;
        }
    }
    return rgb;
}

float3 shift_col(float3 rgb, half3 shift)
{
    // RGB->HSV変換
    float3 hsv = rgb2hsv(rgb);

    // HSV操作
    hsv.x += shift.x;
    if (1.0 <= hsv.x)
    {
        hsv.x -= 1.0;
    }
    hsv.y *= shift.y;
    hsv.z *= shift.z;

    // HSV->RGB変換
    return hsv2rgb(hsv);
}

float3 ColorTemputure(float3 rgb, float temputure)
{
    float3 col = rgb;
    if (temputure > 0)
    {
        col.b -= (rgb.b * temputure);

    }
    else if (temputure < 0)
    {
        col.b -= (rgb.b * temputure);
    }
    return col;
}