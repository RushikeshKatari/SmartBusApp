package com.smartbus.auth.entity;
import jakarta.persistence.*; import java.time.Instant; import java.util.UUID;
@Entity @Table(name="login_qr_tokens") public class LoginQrToken { @Id public UUID id; @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="student_id") public Student student; public UUID token; @Column(name="telegram_chat_id") public long telegramChatId; @Column(name="created_at") public Instant createdAt; @Column(name="is_used") public boolean used; @Column(name="used_at") public Instant usedAt; }
