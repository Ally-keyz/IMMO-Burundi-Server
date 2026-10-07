import nodemailer, { type Transporter } from 'nodemailer';
import { env } from '../../config/env.js';

let transporter: Transporter | null = null;

function getTransporter(): Transporter | null {
  if (!env.SMTP_HOST || !env.SMTP_FROM) return null;
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: env.SMTP_HOST,
      port: env.SMTP_PORT,
      secure: env.SMTP_SECURE,
      auth: env.SMTP_USER && env.SMTP_PASSWORD ? { user: env.SMTP_USER, pass: env.SMTP_PASSWORD } : undefined,
    });
  }
  return transporter;
}

function webOrigin(): string {
  return env.WEB_ORIGIN.split(',')[0].trim().replace(/\/$/, '');
}

export function isSmtpConfigured(): boolean {
  return Boolean(env.SMTP_HOST && env.SMTP_FROM);
}

export function buildSetupUrl(token: string): string {
  return `${webOrigin()}/setup-account/${encodeURIComponent(token)}`;
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character] ?? character);
}

export async function sendAgentSetupEmail(input: { email: string; firstName: string; setupToken: string }): Promise<{ sent: boolean; setupUrl: string }> {
  const setupUrl = buildSetupUrl(input.setupToken);
  const transport = getTransporter();
  if (!transport) {
    console.warn(`[MAIL] SMTP is not configured. Agent setup link: ${setupUrl}`);
    return { sent: false, setupUrl };
  }

  const safeName = escapeHtml(input.firstName);
  const safeUrl = escapeHtml(setupUrl);
  await transport.sendMail({
    from: { name: env.SMTP_FROM_NAME, address: env.SMTP_FROM },
    to: input.email,
    subject: 'Set up your IMMO BURUNDI agent account',
    text: `Hello ${input.firstName},\n\nSet up your IMMO BURUNDI agent account and choose your password here: ${setupUrl}\n\nThis link expires in ${env.SETUP_ACCOUNT_TTL_HOURS} hours.`,
    html: `<div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#191919"><h2>Welcome to IMMO BURUNDI</h2><p>Hello ${safeName},</p><p>Your agent account has been created. Choose a password and activate your account using the secure link below.</p><p><a href="${safeUrl}" style="display:inline-block;background:#191919;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none">Set up my account</a></p><p>This link expires in ${env.SETUP_ACCOUNT_TTL_HOURS} hours.</p><p>If you did not expect this message, contact the IMMO BURUNDI administration team.</p></div>`,
  });
  return { sent: true, setupUrl };
}
