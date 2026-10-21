package com.fenglin.springboottest.common;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.security.SecureRandom;
import java.util.Base64;
import javax.imageio.ImageIO;

/**
 * 图形验证码生成工具（服务端渲染，无额外依赖）。
 * 与前端风格一致：暗色背景 + 金色系字符 + 干扰线/点。
 */
public class CaptchaUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // 去掉易混淆字符
    private static final int WIDTH = 112;
    private static final int HEIGHT = 42;
    private static final int LENGTH = 4;
    private static final String[] COLORS = { "#d8c193", "#ececec", "#c9a96a", "#b9a07a" };

    public static class Captcha {
        public String code;
        public String base64; // data:image/png;base64,...
    }

    public static Captcha generate() throws Exception {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setColor(new Color(28, 28, 28));
        g.fillRect(0, 0, WIDTH, HEIGHT);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        // 干扰线
        for (int i = 0; i < 4; i++) {
            g.setColor(new Color(201, 169, 106, RANDOM.nextInt(80) + 40));
            g.drawLine(RANDOM.nextInt(WIDTH), RANDOM.nextInt(HEIGHT),
                    RANDOM.nextInt(WIDTH), RANDOM.nextInt(HEIGHT));
        }
        // 干扰点
        for (int i = 0; i < 22; i++) {
            g.setColor(new Color(201, 169, 106, RANDOM.nextInt(60) + 20));
            g.fillRect(RANDOM.nextInt(WIDTH), RANDOM.nextInt(HEIGHT), 2, 2);
        }

        StringBuilder code = new StringBuilder();
        int step = WIDTH / (LENGTH + 1);
        for (int i = 0; i < LENGTH; i++) {
            char c = CHARS.charAt(RANDOM.nextInt(CHARS.length()));
            code.append(c);
            g.setColor(Color.decode(COLORS[RANDOM.nextInt(COLORS.length)]));
            g.setFont(new Font("Georgia", Font.BOLD, RANDOM.nextInt(7) + 22));
            int dx = step * (i + 1);
            int dy = HEIGHT / 2 + RANDOM.nextInt(7) - 3;
            g.translate(dx, dy);
            double angle = (RANDOM.nextInt(45) - 22) * Math.PI / 180;
            g.rotate(angle);
            g.drawString(String.valueOf(c), -10, 8);
            g.rotate(-angle);
            g.translate(-dx, -dy);
        }
        g.dispose();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);
        String base64 = "data:image/png;base64," + Base64.getEncoder().encodeToString(baos.toByteArray());

        Captcha captcha = new Captcha();
        captcha.code = code.toString();
        captcha.base64 = base64;
        return captcha;
    }
}
