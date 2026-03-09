from datetime import date
from datetime import datetime
from datetime import timezone

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.models.quota import DailyQuota
from app.models.quota import UserAccount
from app.schemas.chat import QuotaResponse


class QuotaExceededError(RuntimeError):
    def __init__(self, quota: QuotaResponse):
        super().__init__("Daily quota exhausted.")
        self.quota = quota


class QuotaService:
    prepare_counter = "prepare"
    respond_counter = "respond"
    entity_summary_counter = "entity_summary"
    attachment_inspect_counter = "attachment_inspect"

    def __init__(self, settings: Settings):
        self.settings = settings

    def ensure_user(self, session: Session, client_id: str) -> UserAccount:
        user_account = (
            session.query(UserAccount)
            .filter(UserAccount.client_id == client_id)
            .one_or_none()
        )
        if user_account is not None:
            return user_account

        user_account = UserAccount(client_id=client_id)
        session.add(user_account)
        try:
            session.commit()
        except IntegrityError:
            session.rollback()
            return (
                session.query(UserAccount)
                .filter(UserAccount.client_id == client_id)
                .one()
            )

        session.refresh(user_account)
        return user_account

    def reserve_prepare(self, session: Session, client_id: str) -> QuotaResponse:
        return self._reserve_counter(
            session,
            client_id,
            self.prepare_counter,
        )

    def reserve_respond(self, session: Session, client_id: str) -> QuotaResponse:
        return self._reserve_counter(
            session,
            client_id,
            self.respond_counter,
        )

    def reserve_entity_summary(
        self,
        session: Session,
        client_id: str,
    ) -> QuotaResponse:
        return self._reserve_counter(
            session,
            client_id,
            self.entity_summary_counter,
        )

    def reserve_attachment_inspect(
        self,
        session: Session,
        client_id: str,
    ) -> QuotaResponse:
        return self._reserve_counter(
            session,
            client_id,
            self.attachment_inspect_counter,
        )

    def current_quota(self, session: Session, client_id: str) -> QuotaResponse:
        _, daily_quota = self._upsert_daily_quota(session, client_id)
        return self._to_response(daily_quota, client_id)

    def _reserve_counter(
        self,
        session: Session,
        client_id: str,
        counter_name: str,
    ) -> QuotaResponse:
        user_account, daily_quota = self._upsert_daily_quota(session, client_id)
        if daily_quota.total_count >= self.settings.default_daily_quota:
            raise QuotaExceededError(self._to_response(daily_quota, client_id))

        now = datetime.now(timezone.utc)
        if counter_name == self.prepare_counter:
            daily_quota.prepare_count += 1
        elif counter_name == self.respond_counter:
            daily_quota.respond_count += 1
        elif counter_name == self.entity_summary_counter:
            daily_quota.entity_summary_count += 1
        elif counter_name == self.attachment_inspect_counter:
            daily_quota.attachment_inspect_count += 1
        else:
            raise ValueError(f"Unsupported quota counter: {counter_name}")

        daily_quota.total_count += 1
        daily_quota.updated_at = now
        user_account.last_seen_at = now
        session.commit()
        session.refresh(daily_quota)
        return self._to_response(daily_quota, client_id)

    def _upsert_daily_quota(
        self,
        session: Session,
        client_id: str,
    ) -> tuple[UserAccount, DailyQuota]:
        user_account = self.ensure_user(session, client_id)
        quota_day = date.today().isoformat()
        daily_quota = (
            session.query(DailyQuota)
            .filter(DailyQuota.client_id == client_id, DailyQuota.quota_day == quota_day)
            .one_or_none()
        )
        if daily_quota is not None:
            return user_account, daily_quota

        daily_quota = DailyQuota(client_id=client_id, quota_day=quota_day)
        session.add(daily_quota)
        try:
            session.commit()
        except IntegrityError:
            session.rollback()
            daily_quota = (
                session.query(DailyQuota)
                .filter(
                    DailyQuota.client_id == client_id,
                    DailyQuota.quota_day == quota_day,
                )
                .one()
            )
            user_account = self.ensure_user(session, client_id)
            return user_account, daily_quota

        session.refresh(daily_quota)
        return user_account, daily_quota

    def _to_response(self, daily_quota: DailyQuota, client_id: str) -> QuotaResponse:
        remaining_total = max(
            0,
            self.settings.default_daily_quota - daily_quota.total_count,
        )
        return QuotaResponse(
            client_id=client_id,
            quota_day=daily_quota.quota_day,
            daily_limit=self.settings.default_daily_quota,
            total_used=daily_quota.total_count,
            remaining_total=remaining_total,
            prepare_count=daily_quota.prepare_count,
            respond_count=daily_quota.respond_count,
            entity_summary_count=daily_quota.entity_summary_count,
            attachment_inspect_count=daily_quota.attachment_inspect_count,
            updated_at=daily_quota.updated_at,
            remaining_prepare=remaining_total,
            remaining_respond=remaining_total,
        )
